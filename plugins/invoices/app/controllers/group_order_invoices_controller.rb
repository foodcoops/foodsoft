class GroupOrderInvoicesController < OrderInvoicesControllerBase
  include InvoiceHelper
  include SendGroupOrderInvoicePdf

  def show
    @group_order_invoice = GroupOrderInvoice.find(params[:id])
    raise RecordInvalid unless FoodsoftConfig[:contact][:tax_number]

    respond_to do |format|
      format.html do
        send_group_order_invoice_pdf @group_order_invoice if FoodsoftConfig[:contact][:tax_number]
      end
      format.pdf do
        send_group_order_invoice_pdf @group_order_invoice if FoodsoftConfig[:contact][:tax_number]
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: root_path, notice: I18n.t('errors.general'), alert: I18n.t('errors.general_msg', msg: "#{e} " + I18n.t('errors.check_tax_number'))
  end

  def create
    go = GroupOrder.find(params[:group_order])
    @order = go.order
    begin
      GroupOrderInvoice.find_or_create_by!(group_order_id: go.id)
      respond_to do |format|
        format.js
      end
    rescue StandardError => e
      redirect_back fallback_location: root_path, notice: I18n.t('errors.general'), alert: I18n.t('errors.general_msg', msg: e)
    end
  end

  def destroy
    goi = GroupOrderInvoice.find(params[:id])
    @order = goi.group_order.order
    goi.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  def create_multiple
    invoice_date = params[:group_order_invoice][:invoice_date]
    order_id = params[:group_order_invoice][:order_id]
    @order = Order.find(order_id)
    gos = GroupOrder.where(order_id: order_id)
    gos.each do |go|
      goi = GroupOrderInvoice.find_or_create_by!(group_order_id: go.id)
      goi.invoice_date = invoice_date
      goi.invoice_number = generate_invoice_number(goi, 1)
      goi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def select_all_sepa_sequence_type
    @order = Order.find(params[:order_id])
    @group_order_invoices = @order.group_orders.map(&:group_order_invoice).compact
    return unless params[:sepa_sequence_type]

    @sepa_sequence_type = params[:sepa_sequence_type]
    @group_order_invoices.each do |goi|
      goi.sepa_sequence_type = params[:sepa_sequence_type]
      goi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def toggle_all_paid
    @order = Order.find(params[:order_id])
    @group_order_invoices = @order.group_orders.map(&:group_order_invoice).compact
    @group_order_invoices.each do |goi|
      goi.paid = !ActiveRecord::Type::Boolean.new.deserialize(params[:paid])
      goi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def toggle_all_sepa_downloaded
    @order = Order.find(params[:order_id])
    @group_order_invoices = @order.group_orders.map(&:group_order_invoice).compact
    @group_order_invoices.each do |goi|
      goi.sepa_downloaded = !ActiveRecord::Type::Boolean.new.deserialize(params[:sepa_downloaded])
      goi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def download_all
    order = Order.find(params[:order_id])
    invoices = order.group_orders.map(&:group_order_invoice)
    pdf = {}
    file_paths = []
    temp_file = Tempfile.new("all_invoices_for_order_#{order.id}.zip")
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      invoices.each do |invoice|
        pdf = create_invoice_pdf(invoice)
        file_path = File.join('tmp', pdf.filename)
        File.open(file_path, 'w:ASCII-8BIT') do |file|
          file.write(pdf.to_pdf)
        end
        file_paths << file_path
        zipfile.add(pdf.filename, file_path) unless zipfile.find_entry(pdf.filename)
      end
    end
    zip_data = File.read(temp_file.path)
    file_paths.each do |file_path|
      File.delete(file_path)
    end
    respond_to do |format|
      format.html do
        send_data(zip_data, type: 'application/zip', filename: "#{l order.ends, format: :file}-#{order.supplier.name}-#{order.id}.zip", disposition: 'attachment')
      end
    end
  end

  protected

  def invoice_class
    GroupOrderInvoice
  end

  def related_group_order(invoice)
    invoice.group_order
  end
end
