require 'spec_helper'

describe Admin::UserManagement::ResellersController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => admin_user_management_resellers_path}.should route_to('admin/user_management/resellers#index')
      {:post => admin_user_management_resellers_path}.should route_to('admin/user_management/resellers#create')
    end
  end
  context "Browse resellers" do
    it "should display all the resellers sorted by creation time" do
      reseller1 = Fabricate(:reseller)
      reseller2 = Fabricate(:reseller)

      get :index

      assigns[:resellers].should == [reseller2, reseller1]
      response.should be_success
    end
  end
end