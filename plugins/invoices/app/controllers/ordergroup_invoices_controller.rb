class OrdergroupInvoicesController < OrderInvoicesControllerBase
  include SendGroupOrderInvoicePdf

  # def new
  #   @ordergroup_invoice = OrdergroupInvoice.new
  #   @ordergroup_invoice.payment_method = FoodsoftConfig[:ordergroup_invoices][:payment_method] || I18n.t('activerecord.attributes.ordergroup_invoice.payment_method')
  #   @ordergroup_invoice.sepa_sequence_type = params[:sepa_sequence_type]
  # end

  def show
    @ordergroup_invoice = OrdergroupInvoice.find(params[:id])
    raise RecordInvalid unless FoodsoftConfig[:contact][:tax_number]

    respond_to do |format|
      format.html do
        send_group_order_invoice_pdf @ordergroup_invoice if FoodsoftConfig[:contact][:tax_number]
      end
      format.pdf do
        send_group_order_invoice_pdf @ordergroup_invoice if FoodsoftConfig[:contact][:tax_number]
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: root_path, notice: I18n.t('errors.general'), alert: I18n.t('errors.general_msg', msg: "#{e} " + I18n.t('errors.check_tax_number'))
  end

  def create
    mgo = MultiGroupOrder.find(params[:multi_group_order_id])
    @multi_order = mgo.multi_order
    begin
      OrdergroupInvoice.create(multi_group_order_id: mgo.id)
      respond_to do |format|
        format.js
      end
    rescue StandardError => e
      redirect_back fallback_location: root_path, notice: I18n.t('errors.general'), alert: I18n.t('errors.general_msg', msg: e)
    end
  end

  def destroy
    oi = OrdergroupInvoice.find(params[:id])
    @multi_order = oi.multi_group_order.multi_order
    oi.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  def create_multiple
    invoice_date = params[:ordergroup_invoice][:invoice_date]
    multi_order_id = params[:ordergroup_invoice][:multi_order_id]
    @multi_order = MultiOrder.find(multi_order_id)
    multi_group_orders = MultiGroupOrder.where(multi_order_id: multi_order_id)
    multi_group_orders.each do |multi_group_order|
      ordergroup_invoice = OrdergroupInvoice.find_or_create_by!(multi_group_order: multi_group_order)
      ordergroup_invoice.invoice_date = invoice_date
      ordergroup_invoice.invoice_number = ordergroup_invoice.generate_invoice_number(ordergroup_invoice, 1)
      ordergroup_invoice.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def send_all
    @multi_order = MultiOrder.find(params[:multi_order_id])
    @ordergroup_invoices = @multi_order.multi_group_orders.map(&:ordergroup_invoice).compact
    @ordergroup_invoices.each(&:send_invoice)
    respond_to do |format|
      format.html do
        redirect_to finance_order_index_path, notice: I18n.t('ordergroup_invoices.send_all.success')
      end
    end
  end

  def select_all_sepa_sequence_type
    @multi_order = MultiOrder.find(params[:multi_order_id])
    @ordergroup_invoices = @multi_order.multi_group_orders.map(&:ordergroup_invoice).compact
    return unless params[:sepa_sequence_type]

    @sepa_sequence_type = params[:sepa_sequence_type]
    @ordergroup_invoices.each do |oi|
      oi.sepa_sequence_type = params[:sepa_sequence_type]
      oi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def toggle_all_paid
    @multi_order = MultiOrder.find(params[:multi_order_id])
    @ordergroup_invoices = @multi_order.multi_group_orders.map(&:ordergroup_invoice).compact
    @ordergroup_invoices.each do |oi|
      oi.paid = !ActiveRecord::Type::Boolean.new.deserialize(params[:paid])
      oi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def toggle_all_sepa_downloaded
    @multi_order = MultiOrder.find(params[:multi_order_id])
    @ordergroup_invoices = @multi_order.multi_group_orders.map(&:ordergroup_invoice).compact
    @ordergroup_invoices.each do |goi|
      goi.sepa_downloaded = !ActiveRecord::Type::Boolean.new.deserialize(params[:sepa_downloaded])
      goi.save!
    end
    respond_to do |format|
      format.js
    end
  end

  def download_all
    multi_order = MultiOrder.find(params[:multi_order_id])

    invoices = multi_order.multi_group_orders.map(&:ordergroup_invoice)
    pdf = {}
    file_paths = []
    temp_file = Tempfile.new("all_invoices_for_multi_order_#{multi_order.id}.zip")
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
        send_data(zip_data, type: 'application/zip', filename: "#{l multi_order.ends, format: :file}-#{multi_order.orders.first.supplier.name}-#{multi_order.id}.zip", disposition: 'attachment')
      end
    end
  end

  protected

  def invoice_class
    OrdergroupInvoice
  end

  def related_group_order(invoice)
    invoice.multi_group_order
  end
end
