require 'spec_helper'

describe Admin::ClientItemController do
  login_admin

  context "Update Client Price" do

    context "routes" do
      it "should route requests correctly" do
        {:get => admin_client_item_edit_path(:id => "1")}.should route_to('admin/client_item#edit', :id => "1")
        {:put => admin_client_item_update_path(:id => "1")}.should route_to('admin/client_item#update', :id => "1")
      end
    end

    context "add client price to client item" do

      it "should render edit page for client item" do
        client_item = Fabricate(:client_item)
        get :edit, :id => client_item.id
        assigns[:client_item].should == client_item
        response.should be_success
        response.should render_template(:edit)
      end

      it "should add client price" do
        client_item = Fabricate(:client_item)
        post :update, :id => client_item.id, :client_item => {:client_price => "33333"}

        client_item.reload
        client_item.client_price.should == 33_333
        client_item.margin.should == client_item.calculate_margin
        flash[:notice].should == "The Item %s was successfully updated" % client_item.title
        response.should redirect_to admin_client_catalog_path(client_item.client.id)
      end

      it "should not update client price for invalid value" do
        client_item = Fabricate(:client_item)
        post :update, :id => client_item.id, :client_item => {:client_price => "invalid price"}

        client_item.client_price.should == 9_000
        client_item.margin.should == client_item.calculate_margin
        response.should render_template(:edit)
      end
    end

  end
end
