require 'spec_helper'

describe Admin::ClientCatalogController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => admin_client_catalog_path(:id => "1")}.should route_to('admin/client_catalog#show', :id => "1")
      {:put => admin_remove_from_client_catalog_path(:id => '1', :client_item_id => '2')}.should route_to('admin/client_catalog#remove_item', :id => '1', :client_item_id => '2')
    end
  end

  context "browse client items" do

    it "should show all client items for a client sorted by creation date" do
      client = Fabricate(:client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog)

      get :show, :id => client_item1.client.id

      assigns[:client_items].should == [client_item2, client_item1]
      assigns[:average_client_margin].should == 12.5
      response.should be_success
      response.should render_template(:show)
    end

    it "should show alert message if no client item present" do
      client = Fabricate(:client)

      get :show, :id => client.id

      flash[:info].should == "Please add some items to this Client Catalog"
    end

    it "should not show alert message if no client item present in result of applied filter" do
      client = Fabricate(:client)

      get :show, :id => client.id, :q => {:item_preferred_supplier_supplier_id_eq => 1}

      flash[:alert].should be_nil
    end

    it "should show only client items which are not deleted for a client sorted by creation date" do
      client = Fabricate(:client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      client_item3 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => true)

      get :show, :id => client_item1.client.id

      assigns[:client_items].should == [client_item2, client_item1]
      assigns[:client_items].should_not include(client_item3)

      response.should be_success
      response.should render_template(:show)
    end

  end

  context "add items" do
    it "should add selected items" do
      client = Fabricate(:client)
      item1 = Fabricate(:item)
      item2 = Fabricate(:item)
      put :update, {:id => client.id, :item_ids => [item1.id, item2.id]}

      client.client_items.count.should == 2
      flash[:notice].should == "2 Item(s) have been added to the #{client.client_name} Client Catalog"
      response.should redirect_to(admin_client_catalog_path)
    end

    it "should not add same item twice" do
      client = Fabricate(:client)
      item = Fabricate(:item)
      put :update, {:id => client.id, :item_ids => [item.id]}
      put :update, {:id => client.id, :item_ids => [item.id]}
      client.client_items.count.should == 1
      response.should redirect_to(admin_client_catalog_path)
    end

    it "should not add items if base price is not present for any item" do
      client = Fabricate(:client)
      item = Fabricate(:item, :bvc_price => nil)
      put :update, {:id => client.id, :item_ids => [item.id]}
      client.client_items.count.should == 0
      flash[:alert].should == "No Items were added to the #{client.client_name} Client Catalog. Some Items do not have a Base Price assigned to them."
      response.should redirect_to(edit_admin_client_catalog_path)
    end

    it "should not add items if base price is not present for one of the items" do
      client = Fabricate(:client)
      item1 = Fabricate(:item)
      item2 = Fabricate(:item, :bvc_price => nil)
      put :update, {:id => client.id, :item_ids => [item1.id, item2.id]}
      client.client_items.count.should == 0
      flash[:alert].should == "No Items were added to the #{client.client_name} Client Catalog. Some Items do not have a Base Price assigned to them."
      response.should redirect_to(edit_admin_client_catalog_path)
    end

    it "should not add items that are not selected" do
      client = Fabricate(:client)
      put :update, {:id => client.id, :item_ids => ""}

      flash[:alert].should == "Please select at least one Item"
      response.should redirect_to(edit_admin_client_catalog_path)
    end
  end

  context "Remove items" do
    it "should remove items from client catalog" do
      client = Fabricate(:client)
      item = Fabricate(:item, :bvc_price => nil)
      client_item = Fabricate(:client_item, :item_id => item.id, :client_catalog => client.client_catalog)
      put :remove_item, :client_item_id => client_item.id, :id => client.id
      flash[:notice].should include("The Item #{client_item.item.title} has been removed from the #{client.client_name} Client Catalog")
      response.should redirect_to(admin_client_catalog_path)
    end

    it "should remove items from client catalog" do
      client = Fabricate(:client)
      item = Fabricate(:item)
      client_item = Fabricate(:client_item, :item_id => item.id, :client_catalog => client.client_catalog, :deleted => true)
      scheme = Fabricate(:scheme, :client => client)
      level_club1 = level_club_for(scheme, 'level1', 'platinum')
      level_club1.catalog.add([client_item])
      level_club1.catalog_items.size.should == 1

      put :remove_item, :client_item_id => client_item.id, :id => client.id
      flash[:notice].should include "The Item #{client_item.item.title} has been removed from the #{client.client_name} Client Catalog"

      level_club1.reload.catalog_items.size.should == 0

      response.should redirect_to(admin_client_catalog_path)
    end


  end

  context "Edit" do
    it "should edit the item in client catalog" do
      client = Fabricate(:client)
      item = Fabricate(:item, :bvc_price => nil)
      Fabricate(:client_item, :item_id => item.id, :client_catalog => client.client_catalog)
      get :edit, "id" => client.id
      response.should be_success
      response.should render_template(:edit)
    end
  end

  context "download csv" do
    it "should download csv for filtered results" do
      client = Fabricate(:client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog)

      get :show, :id => client.id, :q => {:item_title_cont => client_item2.item.title}, :format => :csv

      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include client_item2.item.title
      response.body.should_not include client_item1.item.title
    end
  end
end
