# frozen_string_literal: true

module OrdersControllerExtensions
  extend ActiveSupport::Concern
  include InvoiceHelper

  included do # rubocop:disable Metrics/BlockLength
    def collective_direct_debit
      return handle_sepa_not_ready unless foodsoft_sepa_ready?

      group_orders = fetch_group_orders
      return if group_orders.nil?

      @order = Order.find(params[:id])
      process_group_orders(group_orders)
    end

    private

    def fetch_group_orders
      case params[:mode]
      when 'all'
        GroupOrder.where(order_id: params[:id])
      when 'selected'
        GroupOrder.where(id: params[:multi_group_order_ids])
      else
        handle_invalid_mode
        nil
      end
    end

    def process_group_orders(group_orders)
      ordergroups = group_orders.map(&:ordergroup)
      sepa_details = analyze_sepa_status(ordergroups, group_orders)

      if sepa_details[:export_allowed] && group_orders.present?
        generate_sepa_export(group_orders, sepa_details)
      else
        handle_export_not_allowed(sepa_details[:not_possible_names])
      end
    end

    def analyze_sepa_status(ordergroups, group_orders)
      possible_names = ordergroups.map { |og| og.name if og.sepa_possible? }.compact_blank
      not_possible_names = ordergroups.map(&:name) - possible_names
      export_allowed = ordergroups.map(&:sepa_possible?).exclude?(false) &&
                       group_orders.map { |go| go.group_order_invoice.present? }.exclude?(false)

      {
        export_allowed: export_allowed,
        possible_names: possible_names,
        not_possible_names: not_possible_names
      }
    end

    def generate_sepa_export(group_orders, sepa_details)
      respond_to do |format|
        format.html { export_sepa_html(group_orders) }
        format.xml  { export_sepa_xml(group_orders, sepa_details) }
        format.js
      end
    end

    def export_sepa_html(group_orders)
      collective_debit = OrderCollectiveDirectDebitXml.new(group_orders)
      mark_invoices_downloaded(group_orders)
      send_data collective_debit.xml_string,
                filename: "#{@order.name}_Sammellastschrift.xml",
                type: 'text/xml'
    rescue StandardError => e
      handle_export_error(e, group_orders)
    end

    def export_sepa_xml(group_orders, sepa_details)
      mark_invoices_downloaded(group_orders)
      collective_debit = OrderCollectiveDirectDebitXml.new(group_orders)
      send_data collective_debit.xml_string,
                filename: "#{@order.name}_Sammellastschrift.xml",
                type: 'text/xml'
    rescue StandardError => e
      handle_xml_export_error(e, group_orders, sepa_details)
    end

    def handle_sepa_not_ready
      respond_to do |format|
        format.html { redirect_to_finance_with_alert('activerecord.attributes.group_order_invoice.links.sepa_not_ready') }
        format.xml  { redirect_to_finance_with_alert('activerecord.attributes.group_order_invoice.links.sepa_not_ready') }
        format.js
      end
    end

    def handle_invalid_mode
      redirect_to_finance_with_alert('orders.collective_direct_debit.alert', ordergroup_names: '')
    end

    def mark_invoices_downloaded(group_orders)
      group_orders.map(&:group_order_invoice).each(&:mark_sepa_downloaded)
    end

    def unmark_invoices_downloaded(group_orders)
      group_orders.map(&:group_order_invoice).each(&:unmark_sepa_downloaded)
    end

    def redirect_to_finance_with_alert(key, **options)
      redirect_to finance_order_index_path, alert: I18n.t(key, **options)
    end

    def handle_export_error(error, group_orders)
      unmark_invoices_downloaded(group_orders)
      if error.is_a?(SEPA::Error)
        redirect_to_finance_with_alert('orders.collective_direct_debit.alert', error: error.message)
      else
        redirect_to finance_order_index_path,
                    alert: I18n.t('orders.collective_direct_debit.alert',
                                  ordergroup_names: sepa_details[:not_possible_names].join(', '),
                                  error: error.message)
      end
    end

    def handle_xml_export_error(error, group_orders, sepa_details)
      unmark_invoices_downloaded(group_orders)
      error_message = if error.is_a?(SEPA::Error)
                        { error: error.message }
                      else
                        { error: I18n.t('orders.collective_direct_debit.alert',
                                        ordergroup_names: sepa_details[:not_possible_names].join(', '),
                                        error: error.message) }
                      end
      render json: error_message
    end

    def handle_export_not_allowed(not_possible_names)
      respond_to do |format|
        format.html do
          redirect_to_finance_with_alert('orders.collective_direct_debit.alert',
                                         ordergroup_names: not_possible_names.join(', '),
                                         error: '')
        end
        format.xml do
          render json: { error: I18n.t('orders.collective_direct_debit.alert',
                                       ordergroup_names: not_possible_names.join(', '),
                                       error: '') }
        end
        format.js
      end
    end
  end
end
