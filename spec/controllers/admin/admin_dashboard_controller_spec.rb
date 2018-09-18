require 'spec_helper'

describe Admin::AdminDashboardController do
  before :each do
    @client_manager_admin_user = Fabricate(:client_manager_admin_user)
    sign_in @client_manager_admin_user
  end
  context "routes" do
    it "should route correctly" do
      {:get => admin_dashboard_path}.should route_to('admin/admin_dashboard#show')
    end
  end

  it "should return new client manager dashboard" do
    AdminDashboard.should_receive(:new).with(@client_manager_admin_user).exactly(1).times
    get :show
  end
end