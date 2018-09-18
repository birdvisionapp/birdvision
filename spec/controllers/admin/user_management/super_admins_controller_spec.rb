require 'spec_helper'

describe Admin::UserManagement::SuperAdminsController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => admin_user_management_super_admins_path}.should route_to('admin/user_management/super_admins#index')
      {:get => new_admin_user_management_super_admin_path}.should route_to('admin/user_management/super_admins#new')
    end
  end

  context "super admin" do
    it "should list existing super admin users" do
      another_super_admin = Fabricate(:admin_user, :username => "super_admin")
      Fabricate(:admin_user, :username => "client_manager", :role => AdminUser::Roles::CLIENT_MANAGER)
      get :index
      assigns[:admin_users].should == [@admin, another_super_admin]
    end

    it "should render new form" do
      get :new
      response.should be_success
      response.should render_template(:new)
    end

    it "should allow creating new super admin users" do
      post :create, {:admin_user => {:username => 'super_admin', :email => 'admin@mailinator.com'}}
      AdminUser.count.should == 2
      response.should redirect_to admin_user_management_super_admins_path
    end

    it "should not create new super admin if attributes are not given properly" do
      post :create, {:admin_user => {:username => 'super_admin'}}
      AdminUser.count.should == 1
      response.should render_template(:new)
    end
  end
end
