class Admin::AdminDashboardController < Admin::AdminController
  def show
    @dashboard = AdminDashboard.new(current_admin_user)
  end
end