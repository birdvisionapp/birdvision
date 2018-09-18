class Admin::UserManagement::ClientResellersController < Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :all, :except => [:destroy, :show]
  before_filter :get_reseller

  def new
    @client_reseller = ClientReseller.new
    3.times { @client_reseller.slabs.build }
  end

  def create
    @client_reseller = ClientReseller.new(params[:client_reseller])
    @client_reseller.reseller_id = @reseller_id
    create! { admin_user_management_resellers_path }
  end

  def update
    update! { admin_user_management_resellers_path }
  end

  def unassign
    reseller = Reseller.find(params[:reseller_id])
    client = ClientReseller.find(params[:id]).client
    reseller.unassign(client)
    redirect_to edit_admin_user_management_reseller_path(reseller), :notice => "#{client.client_name} successfully unassigned"
  end

  private
  def get_reseller
    @reseller_id = params[:reseller_id]
  end
end