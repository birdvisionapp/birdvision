class Admin::UserManagement::ResellersController < Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :all, :except => [:show]

  def index
    @search = Reseller.accessible_by(current_ability).includes(:admin_user).available.search(params[:q])
    @resellers = @search.result.order("resellers.created_at desc").page(params[:page])
  end

  def destroy
    @reseller.admin_user.soft_delete
    flash[:notice] = App::Config.messages[:reseller][:deleted] % [@reseller.name]
    redirect_to admin_user_management_resellers_path
  end

end
