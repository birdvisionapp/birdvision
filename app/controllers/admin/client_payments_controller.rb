class Admin::ClientPaymentsController < Admin::AdminController

  load_and_authorize_resource :client_invoice
  load_and_authorize_resource :client_payment, :through => :client_invoice, :parent => false
  
  inherit_resources

  actions :all, :only => [:show, :new, :create, :edit, :update]
  
  before_filter :load_client_invoice, :only => [:new, :create, :edit, :update]

  def new
    @client_payment = @client_invoice.build_client_payment
  end

  def create
    @client_payment = @client_invoice.build_client_payment(params[:client_payment])
    create! { admin_client_invoices_path }
  end

  def update
    @client_payment = @client_invoice.client_payment(params[:client_payment])
    update! { admin_client_invoices_path }
  end

  private

  def interpolation_options
    {:resource_description => @client_payment.client_invoice.invoice_number}
  end

  def load_client_invoice
    @client_invoice = ClientInvoice.accessible_by(current_ability).find(params[:client_invoice_id])
  end

end