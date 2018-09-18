class Admin::ClientInvoicesController < Admin::AdminController

  load_and_authorize_resource
  
  inherit_resources

  actions :all, :except => [:edit, :update]

  def index
    @search = ClientInvoice.available.includes(init_includes([:client_payment])).accessible_by(current_ability).select('client_invoices.id, client_invoices.client_id, client_invoices.inv_sequence, client_invoices.invoice_date, client_invoices.invoice_type, client_invoices.amount_breakup, client_invoices.points, client_invoices.status').search(params[:q])
    @search.sorts = 'updated_at desc' if @search.sorts.empty?
    @invoice_stats = @search.result.group(:status).count
    @client_invoices = @search.result.page(params[:page])
    @client_budget = ClientBudget.new(Client.accessible_by(current_ability).pluck(:id))
  end

  def create
    create! { admin_client_invoices_path }
  end

  def show
    @client_invoice = ClientInvoice.accessible_by(current_ability).find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ClientInvoicePdf.new(@client_invoice, view_context)
        send_data pdf.render, filename: @client_invoice.filename, disposition: 'inline', type: 'application/pdf'
      end
    end
  end

  def destroy
    @client_invoice.soft_delete
    redirect_to admin_client_invoices_path, :flash => {:notice => App::Config.messages[:client_invoice][:cancelled] % [@client_invoice.invoice_number]}
  end

  private

  def interpolation_options
    {:resource_description => @client_invoice.invoice_number}
  end

end