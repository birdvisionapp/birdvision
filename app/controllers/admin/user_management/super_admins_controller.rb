class Admin::UserManagement::SuperAdminsController < Admin::AdminController
  inherit_resources
  load_and_authorize_resource :class => AdminUser
  actions :all, :except => [:show]
  defaults :resource_class => AdminUser, :collection_name => 'admin_users', :instance_name => 'admin_user'
  before_filter :set_msp

  def index
    @search = @object.available.where(role: AdminUser::Roles::SUPER_ADMIN).non_msp_users(is_super_admin? && !params[:msp_id]).search(params[:q])
    @admin_users = @search.result.page(params[:page])
  end

  def create
    @admin_user = @object.new(params[:admin_user])
    @admin_user.role = AdminUser::Roles::SUPER_ADMIN
    @admin_user.msp_id = @msp && @msp.id || current_admin_user.msp_id if @msp || is_msp_admin?
    create!{ [:admin, :user_management, @msp, :super_admins] }
  end

  def update
    update! { [:admin, :user_management, @msp, :super_admins] }
  end

  def transfer_rights
    admin_user = AdminUser.find(params[:admin_user][:id]) if params[:admin_user][:id].present?
    if admin_user && admin_user.update_attribute(:manage_roles, true)
      flash[:notice] = "Successfully transferred User Management rights to #{admin_user.username}."
      current_admin_user.update_attribute(:manage_roles, false)
    else
      flash[:alert] = "Please select Super Admin to transfer User Management rights."
    end
    redirect_to admin_user_management_dashboard_path
  end

  def destroy
    delete_slug = :cant_delete
    unless @admin_user.manage_roles?
      @admin_user.soft_delete
      delete_slug = :deleted
    end
    flash[(delete_slug == :deleted) ? :notice : :alert] = App::Config.messages[:super_admin][delete_slug] % [@admin_user.username]
    redirect_to [:admin, :user_management, @msp, :super_admins]
  end

  private

  def set_msp
    @msp = Msp.accessible_by(current_ability).where(id: params[:msp_id]).first
    @object = AdminUser.accessible_by(current_ability)
    if @msp.present?
      @object = @msp.admin_users
    end
  end

end
