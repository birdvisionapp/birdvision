class Admin::UserManagement::ClientManagersController < Admin::AdminController
  inherit_resources
  load_and_authorize_resource
  actions :all

  def create
    create! { admin_user_management_client_managers_path }
  end

  def index
    @search = ClientManager.accessible_by(current_ability).includes(:admin_user).available.search(params[:q])
    @client_managers = @search.result.page(params[:page])
  end

  def destroy
    @client_manager.admin_user.soft_delete
    flash[:notice] = App::Config.messages[:client_manager][:deleted] % [@client_manager.name]
    redirect_to admin_user_management_client_managers_path
  end
  
end
