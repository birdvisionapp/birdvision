require 'spec_helper'

describe Admin::SchemeCatalogController do
  context "routes" do
    it "should route requests correctly" do
      {:get => admin_scheme_catalog_path(1)}.should route_to("admin/scheme_catalog#show", :id => "1")
    end
  end

  @user = login_admin

  let(:client) { Fabricate(:client) }
  let(:scheme) { Fabricate(:scheme, :client => client) }

  context "show" do
    it "should render catalog" do
      client_item1 = Fabricate(:client_item)
      scheme.catalog.add([client_item1])

      get :show, :id => scheme.id

      assigns[:catalog_items].size.should == 1
      assigns[:scheme].should == scheme
      assigns[:average_client_margin].should == 12.5
    end

    it "should show message for empty scheme catalog" do
      bbd = Fabricate(:scheme, :client => client)

      get :show, :id => bbd.id

      flash[:info].should == "Please add some items to this Scheme Catalog"
    end

    it "should not show message empty scheme catalog for filtered result set" do
      bbd = Fabricate(:scheme, :client => client)

      get :show, :id => bbd.id, :q => {:item_preferred_supplier_supplier_id_eq => 1}

      flash[:alert].should be_nil
    end
  end

  context "edit" do
    it "should show list of valid client items (with price and not deleted)" do
      client_item_without_price = Fabricate(:client_item, :client_price => nil, :client_catalog => client.client_catalog, :deleted => false)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      client_item3 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      deleted_item = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => true)

      get :edit, :id => scheme.id

      assigns[:client_items].to_a.should =~ [client_item2, client_item3]
      assigns[:scheme].should == scheme
    end

    it "should show message for empty scheme catalog" do
      bbd = Fabricate(:scheme, :client => client)

      get :edit, :id => bbd.id

      flash[:info].should == "Add items to the Client catalog and set client prices to start adding items to this Scheme catalog"
    end

    it "should not show message empty scheme catalog for filtered result set" do
      bbd = Fabricate(:scheme, :client => client)

      get :edit, :id => bbd.id, :q => {:item_preferred_supplier_supplier_id_eq => 1}

      flash[:alert].should be_nil
    end

  end

  context "update" do
    it "should add client items to scheme and level-club catalog for a 1x1 scheme" do
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog)

      put :update, {:id => scheme.id, :client_item_ids => [client_item.id]}

      response.should redirect_to(admin_scheme_catalog_path(scheme))
      flash[:notice].should include("1 Item(s)")
      flash[:notice].should include("#{scheme.name}")

      scheme.reload.catalog.size.should == 1
    end

    it "should redirect to edit page if no items were selected" do
      put :update, {:id => scheme.id}

      response.should redirect_to(edit_admin_scheme_catalog_path(scheme))

      flash[:alert].should == "Please select items"

      scheme.reload.catalog.size.should == 0
    end

    it "should not add client items to level-club catalog for a non 1x1 scheme" do
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog)
      scheme_3x3 = Fabricate(:scheme_3x3, :name => "scheme_3x3", :client => client)

      put :update, {:id => scheme_3x3.id, :client_item_ids => [client_item.id]}

      response.should redirect_to(admin_scheme_catalog_path(scheme_3x3))
      flash[:notice].should include("1 Item(s)")
      flash[:notice].should include("#{scheme_3x3.name}")

      scheme_3x3.reload.catalog.size.should == 1
      scheme_3x3.reload.level_clubs.first.catalog.size.should == 0
    end

  end

  it "should remove client item from a scheme for point based items" do
    client_item = Fabricate(:client_item, :client_catalog => client.client_catalog, :item => Fabricate(:item, :title => "Item title"))
    scheme.catalog.add([client_item])
    level_club = level_club_for(scheme, 'level1', 'platinum')
    level_club.catalog.add([client_item])
    put :remove_item, {:id => scheme.id, :client_item_id => client_item.id}

    response.should redirect_to(admin_scheme_catalog_path(scheme))
    scheme.reload.catalog.size.should == 0
    level_club.catalog.size.should == 0
    ClientItem.find(client_item.id).deleted?.should be_false
    flash[:notice].should include "Successfully removed Item title from the Scheme catalog and from the relevant level club catalogs"
  end

  context "download csv" do

    it "should download csv for filtered results" do
      client_item1 = Fabricate(:client_item)
      client_item2 = Fabricate(:client_item)
      scheme.catalog.add([client_item1, client_item2])

      get :show, :id => scheme.id, :q => {:client_item_item_title_cont => client_item2.item.title}, :format => :csv

      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include client_item2.item.title
      response.body.should_not include client_item1.item.title
    end
  end

end