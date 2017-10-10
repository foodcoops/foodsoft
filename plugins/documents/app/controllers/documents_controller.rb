require 'filemagic'

class DocumentsController < ApplicationController
  before_filter -> { require_plugin_enabled FoodsoftDocuments }

  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "created_at" then "created_at"
               when "name_reverse" then "name DESC"
               when "created_at_reverse" then "created_at DESC"
             end
    else
      sort = "name"
    end

    @documents = Document.page(params[:page]).per(@per_page).order(sort)
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new
    @document.data = params[:document][:data].read
    @document.mime = FileMagic.new(FileMagic::MAGIC_MIME).buffer(@document.data)
    if params[:document][:name] == ''
      name = params[:document][:data].original_filename
      name = File.basename(name)
      @document.name = name.gsub(/[^\w\.\-]/, '_')
    else
      @document.name = params[:document][:name]
    end
    @document.created_by = current_user
    @document.save!
    redirect_to documents_path, notice: t('.notice')
  rescue => error
    redirect_to documents_path, alert: t('.error', error: error.message)
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.created_by == current_user or current_user.role_admin?
      @document.destroy
      redirect_to documents_path, notice: t('.notice')
    else
      redirect_to documents_path, alert: t('.no_right')
    end
  rescue => error
    redirect_to documents_path, alert: t('.error', error: error.message)
  end

  def show
    @document = Document.find(params[:id])
    send_data(@document.data, filename: @document.filename, type: @document.mime)
  end
end
