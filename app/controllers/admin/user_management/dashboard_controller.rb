class Admin::UserManagement::DashboardController < Admin::AdminController

  before_filter :load_admin_users, :only => :home

  def home
    @counts = AdminUser.accessible_by(current_ability).available.group(:role).count
    if is_super_admin?
      @counts['msp'] = Msp.accessible_by(current_ability).count
      @counts.merge!(AdminUser.accessible_by(current_ability).site_super_admins.available.group(:role).count)
    end
  end

  private

  def load_admin_users
    @admin_users = AdminUser.accessible_by(current_ability).non_msp_users(is_super_admin?).select(['admin_users.id', 'admin_users.username']).super_admins(current_admin_user.id).available
  end
  
end
