class Admin::SmsBased::DashboardController < Admin::AdminController

  def home
    redirect_to admin_root_path unless can?(:view, :sms_dashboard)
    @dashboard = SmsBasedDashboard.new(current_admin_user)
  end

end
