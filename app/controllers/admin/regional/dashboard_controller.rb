class Admin::Regional::DashboardController < Admin::AdminController

  def home
    authorize! :view, :regional_dashboard
    @dashboard = AdminDashboard.new(current_admin_user)
  end
  
end