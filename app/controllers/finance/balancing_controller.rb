# encoding: utf-8
class Finance::BalancingController < ApplicationController
  before_filter :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.order(:created_on.desc).limit(8)
    @orders = Order.finished_not_closed
    @unpaid_invoices = Invoice.unpaid
  end

  def list
    @orders = Order.finished.paginate :page => params[:page], :per_page => 10, :order => 'ends DESC'
  end

  def new
    @order = Order.find(params[:order_id])
    flash.now.alert = "Achtung, Bestellung wurde schon abgerechnet" if @order.closed?
    @comments = @order.comments

    if params['sort']
      sort = case params['sort']
             when "name"  then "articles.name"
             when "order_number" then "articles.order_number"
             when "name_reverse"  then "articles.name DESC"
             when "order_number_reverse" then "articles.order_number DESC"
             end
    else
      sort = "id"
    end

    @articles = @order.order_articles.ordered.includes(:article).order(sort)
      
    if params[:sort] == "order_number"
      @articles = @articles.to_a.sort { |a,b| a.article.order_number.gsub(/[^[:digit:]]/, "").to_i <=> b.article.order_number.gsub(/[^[:digit:]]/, "").to_i }
    elsif params[:sort] == "order_number_reverse"
      @articles = @articles.to_a.sort { |a,b| b.article.order_number.gsub(/[^[:digit:]]/, "").to_i <=> a.article.order_number.gsub(/[^[:digit:]]/, "").to_i }
    end

    render layout: false if request.xhr?
  end

  def edit_note
    @order = Order.find(params[:id])
    render :layout => false
  end

  def update_note
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      render :layout => false
    else
      render :action => :edit_note, :layout => false
    end
  end

  # before the order will booked, a view lists all Ordergroups and its order_prices
  def confirm
    @order = Order.find(params[:id])
  end

  # Balances the Order, Update of the Ordergroup.account_balances
  def close
    @order = Order.find(params[:id])
    @order.close!(@current_user)
    redirect_to finance_balancing_url, notice: "Bestellung wurde erfolgreich abgerechnet, die Kontostände aktualisiert."

  rescue => error
    redirect_to finance_balancing_url, alert: "Ein Fehler ist beim Abrechnen aufgetreten: #{error.message}"
  end

  # Close the order directly, without automaticly updating ordergroups account balances
  def close_direct
    @order = Order.find(params[:id])
    @order.close_direct!(@current_user)
    redirect_to finance_balancing_url, notice: "Bestellung wurde geschlossen."
  rescue => error
    redirect_to finance_balancing_url, alert: "Bestellung kann nicht geschlossen werden: #{error.message}"
  end

end
