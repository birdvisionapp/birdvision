require 'spec_helper'

describe Admin::UserManagement::DashboardController do
  login_admin

  it "should route to user management dashboard" do
    {:get => admin_user_management_dashboard_path}.should route_to('admin/user_management/dashboard#home')
  end

  it "should return count of users with different roles" do
    Fabricate(:super_admin_user, :role => AdminUser::Roles::SUPER_ADMIN)
    Fabricate(:client_manager)

    get :home
    response.should be_success

    assigns[:counts].should == {"client_manager"=>1, "super_admin"=>2}
  end
end
