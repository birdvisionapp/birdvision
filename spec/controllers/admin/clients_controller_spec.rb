require 'spec_helper'

describe Admin::ClientsController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:post => admin_clients_path}.should route_to('admin/clients#create')
      {:get => admin_clients_path}.should route_to('admin/clients#index')
      {:get => admin_client_download_report_path(:client_id => 1)}.should route_to('admin/clients#download_report', :client_id => '1')
    end
  end
  context "Browse catalog" do
    it "should display all the clients sorted by creation time" do
      client1 = Fabricate(:client)
      client2 = Fabricate(:client)

      get :index

      assigns[:clients].should == [client2, client1]
      response.should be_success
    end


    it "should go to index after creating a client" do
      post :create, :client => {:client_name => "test client name", :points_to_rupee_ratio => "1", :code => "TCN", :client_url => 'http://client.test.com' }
      Client.count.should == 1
      response.should redirect_to admin_clients_path
    end
  end
end