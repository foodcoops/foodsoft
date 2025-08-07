# frozen_string_literal: true

module OrdersControllerExtensions
  extend ActiveSupport::Concern
  include InvoiceHelper

  included do
    def collective_direct_debit
      if foodsoft_sepa_ready?
        case params[:mode]
        when 'all'
          group_orders = GroupOrder.where(order_id: params[:id])
        when 'selected'
          group_orders = GroupOrder.where(id: params[:group_order_ids])
        else
          redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: '')
        end

        @order = Order.find(params[:id])
        ordergroups = group_orders.map(&:ordergroup)

        export_allowed = !ordergroups.map(&:sepa_possible?).include?(false) && !group_orders.map { |go| go.group_order_invoice.present? }.include?(false)
        group_order_ids = group_orders.map { |go| go.id if go.group_order_invoice.present? }

        sepa_possible_ordergroup_names = ordergroups.map { |ordergroup| ordergroup.name if ordergroup.sepa_possible? }.compact_blank
        sepa_not_possible_ordergroup_names = ordergroups.map(&:name) - sepa_possible_ordergroup_names

        if export_allowed && group_orders.present?
          respond_to do |format|
            format.html do
              collective_debit = OrderCollectiveDirectDebitXml.new(group_orders)
              send_data collective_debit.xml_string, filename: @order.name + '_Sammellastschrift' + '.xml', type: 'text/xml'
              group_orders.map(&:group_order_invoice).each(&:mark_sepa_downloaded)
            rescue SEPA::Error => e
              group_orders.map(&:group_order_invoice).each(&:unmark_sepa_downloaded)
              redirect_to finance_order_index_path, alert: e.message
            rescue StandardError => e
              group_orders.map(&:group_order_invoice).each(&:unmark_sepa_downloaded)
              redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: e.message)
            end
            format.xml do
              group_orders.map(&:group_order_invoice).each(&:mark_sepa_downloaded)
              collective_debit = OrderCollectiveDirectDebitXml.new(group_orders)
              send_data collective_debit.xml_string, filename: @order.name + '_Sammellastschrift' + '.xml', type: 'text/xml'
            rescue SEPA::Error => e
              group_orders.map(&:group_order_invoice).each(&:unmark_sepa_downloaded)
              render json: { error: e.message }
            rescue StandardError => e
              group_orders.map(&:group_order_invoice).each(&:unmark_sepa_downloaded)
              render json: { error: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: e.message) }
            end
            format.js
          end
        else
          respond_to do |format|
            format.html do
              redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: '')
            end
            format.xml do
              render json: { error: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: '') }
            end
            format.js
          end
        end
      else
        respond_to do |format|
          format.html do
            redirect_to finance_order_index_path, alert: "Wichtige SEPA Konfiguration in Administration >> Einstellungen >> Finanzen nicht gesetzt!"
          end
          format.xml do
            redirect_to finance_order_index_path, alert: "Wichtige SEPA Konfiguration in Administration >> Einstellungen >> Finanzen nicht gesetzt!"
          end
          format.js
        end
      end
    end
  end
end
