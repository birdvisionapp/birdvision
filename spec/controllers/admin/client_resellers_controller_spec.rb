require 'spec_helper'

describe Admin::UserManagement::ClientResellersController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => admin_user_management_reseller_add_client_for_reseller_path(:reseller_id => '2')}.should route_to('admin/user_management/client_resellers#new', :reseller_id => '2')
      {:post => admin_user_management_reseller_associate_client_to_reseller_path(:reseller_id => '2')}.should route_to('admin/user_management/client_resellers#create', :reseller_id => '2')
      {:get => admin_user_management_reseller_edit_client_for_reseller_path(:reseller_id => '1', :id => '1')}.should route_to('admin/user_management/client_resellers#edit', :reseller_id => '1', :id => '1')
      {:put => admin_user_management_reseller_update_client_for_reseller_path(:reseller_id => '1', :id => '1')}.should route_to('admin/user_management/client_resellers#update', :reseller_id => '1', :id => '1')
      {:put => admin_user_management_reseller_unassign_client_for_reseller_path(:reseller_id => '1', :id => '1')}.should route_to('admin/user_management/client_resellers#unassign', :reseller_id => '1', :id => '1')
    end

    it "should render new form with reseller id and initialize 3 slabs" do
      get :new, :reseller_id => "1"

      assigns[:reseller_id].should == "1"

      assigns[:client_reseller].should_not be_nil
      assigns[:client_reseller].slabs.length.should == 3

      response.should render_template(:new)
    end

    it "should associate a reseller to given client with given info" do
      post :create, :reseller_id => 1, :client_reseller => {:client_id => "4", :finders_fee => "1000", :payout_start_date => "06-02-2013",
                                                            :slabs_attributes => {"0" => {:lower_limit => "10", :payout_percentage => "1"},
                                                                                  "1" => {:lower_limit => "20", :payout_percentage => "2"},
                                                                                  "2" => {:lower_limit => "30", :payout_percentage => "3"}}
      }

      assigns[:reseller_id].should == "1"
      client_reseller = ClientReseller.where(:client_id => 4, :reseller_id => 1).last
      client_reseller.should_not be_nil
      client_reseller.finders_fee.should == 1000
      client_reseller.slabs.length.should == 3

      response.should redirect_to admin_user_management_resellers_path
    end

    it "should render new, with errors if save fails" do
      post :create, :reseller_id => 1

      assigns[:reseller_id].should == "1"
      assigns[:client_reseller].errors.should_not be_nil

      response.should render_template(:new)
    end

    it "should unassign a reseller from a client" do
      reseller = Fabricate(:reseller)
      client_reseller = Fabricate(:client_reseller, :reseller => reseller)
      put :unassign, :reseller_id => reseller.id, :id => client_reseller.id
      client_reseller.reload.assigned.should == false
      response.should redirect_to edit_admin_user_management_reseller_path(reseller)
      flash[:notice].should == "#{client_reseller.client.client_name} successfully unassigned"
    end
  end
end