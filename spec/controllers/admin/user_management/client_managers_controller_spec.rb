require 'spec_helper'

describe Admin::UserManagement::ClientManagersController do
  login_admin
  context "routes" do
    it "should route requests correctly" do
      {:get => admin_user_management_client_managers_path}.should route_to('admin/user_management/client_managers#index')
    end
  end
  context "index" do

    it "should list all the client managers" do
      first_client_manager = Fabricate(:client_manager)
      second_client_manager1 = Fabricate(:client_manager)

      get :index

      assigns[:client_managers].should == [first_client_manager, second_client_manager1]
      response.should render_template(:index)
      response.should be_success
    end

    it "should create a client manager for valid data" do
      client = Fabricate(:client)

      post :create, :client_manager => {:name => 'Client Manager', :email => 'client_manager@mailinator.com',
                                        :mobile_number => '1234567890', :client_id => client.id}

      response.should redirect_to admin_user_management_client_managers_path
      ClientManager.count.should == 1
    end

    it "should not create a client manager if data is not valid" do
      client = Fabricate(:client)

      post :create, :client_manager => {:name => 'Client Manager', :email => 'iamclientmanager@mailinator.com', :mobile_number => '1234567890', :client_id => client.id}

      response.should redirect_to admin_user_management_client_managers_path
      ClientManager.count.should == 1
    end
  end
end
