# frozen_string_literal: true

class InvoiceMailer < Mailer
  # Sends automatically generated invoicesfor group orders to ordergroup members
  def group_order_invoice(group_order_invoice, user)
    @user = user
    @group_order_invoice = group_order_invoice
    @group_order = group_order_invoice.group_order
    @supplier = @group_order.order.supplier.name
    @group = @group_order.ordergroup
    add_group_order_invoice_attachments(group_order_invoice)
    mail to: user,
         subject: I18n.t('mailer.group_order_invoice.subject', group: @group.name, supplier: @supplier)
  end

  def ordergroup_invoice(ordergroup_invoice, user)
    @user = user
    @ordergroup_invoice = ordergroup_invoice
    @multi_group_order = ordergroup_invoice.multi_group_order
    @multi_order = @multi_group_order.multi_order
    @supplier = @multi_order.orders.map(&:supplier).map(&:name).uniq.join(', ')
    @group = @multi_group_order.ordergroup
    add_ordergroup_invoice_attachments(ordergroup_invoice)
    mail to: user,
         subject: I18n.t('mailer.ordergroup_invoice.subject', group: @group.name, supplier: @supplier)
  end

  def add_group_order_invoice_attachments(group_order_invoice)
    attachment_name = group_order_invoice.name + '.pdf'
    attachments[attachment_name] = GroupOrderInvoicePdf.new(group_order_invoice.load_data_for_invoice).to_pdf
  end

  def add_ordergroup_invoice_attachments(ordergroup_invoice)
    add_group_order_invoice_attachments(ordergroup_invoice)
  end
end
