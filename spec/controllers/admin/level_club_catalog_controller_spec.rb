require 'spec_helper'

describe Admin::LevelClubCatalogController do
  context "routes" do
    it "should route requests correctly" do
      {:get => admin_level_club_catalog_path(1)}.should route_to("admin/level_club_catalog#show", :id => "1")
      {:get => edit_admin_level_club_catalog_path(1)}.should route_to("admin/level_club_catalog#edit", :id => "1")
      {:put => admin_level_club_catalog_path(1)}.should route_to("admin/level_club_catalog#update", :id => "1")
      {:put => admin_remove_from_level_club_catalog_path(:id => 1, :client_item_id => 2)}.should route_to("admin/level_club_catalog#remove_item", :id => "1", :client_item_id => "2")
    end
  end

  login_admin

  let(:client) { Fabricate(:client) }
  let(:scheme) { Fabricate(:scheme) }
  let(:level_club) { level_club_for(scheme, "level1", "platinum") }
  context "show" do
    it "should render catalog" do
      client_item1 = Fabricate(:client_item)
      level_club.catalog.add([client_item1])

      get :show, :id => level_club.id

      assigns[:catalog_items].size.should == 1
      assigns[:level_club].should == level_club
      assigns[:average_client_margin].should == 12.5

    end
  end

  context "edit" do
    it "should show list of valid client items (with price and not deleted)" do
      client_item_without_price = Fabricate(:client_item, :client_price => nil, :client_catalog => client.client_catalog, :deleted => false)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      client_item3 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => false)
      scheme.catalog.add([client_item1, client_item2, client_item3, client_item_without_price])
      client_item1.soft_delete

      get :edit, :id => level_club.id

      assigns[:client_items].to_a.should =~ [client_item2, client_item3]
      assigns[:level_club].should == level_club
    end
  end

  context "update" do
    it "should add client items to level club catalog" do
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog)

      put :update, {:id => level_club.id, :client_item_ids => [client_item.id]}

      response.should redirect_to(admin_level_club_catalog_path(level_club))
      flash[:notice].should == '1 items have been added to the Scheme Level1 catalog'
      level_club.reload.catalog.size.should == 1
    end

    it "should not add the same client item more than once to level club catalog" do
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog)
      level_club.catalog.add([client_item])

      put :update, {:id => level_club.id, :client_item_ids => [client_item.id]}

      flash[:alert].should == "No Items were added. Some items are already present in some Level1 catalog of the scheme - #{scheme.name}"
      response.should redirect_to(edit_admin_level_club_catalog_path(level_club))
      level_club.reload.catalog.size.should == 1
    end

    it "should not add items which are already present in the same level of the same scheme" do
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      level_club.catalog.add([client_item1])
      other_level_club = Fabricate(:level_club, :level => level_club.level, :club_name => "gold", :scheme => scheme)

      put :update, {:id => other_level_club.id, :client_item_ids => [client_item1.id, client_item2.id]}

      response.should redirect_to(edit_admin_level_club_catalog_path(other_level_club))
      flash[:alert].should == "No Items were added. Some items are already present in some Level1 catalog of the scheme - #{scheme.name}"
      other_level_club.reload.catalog.size.should == 0
    end

    it "should redirect to edit page if no items were selected" do
      put :update, {:id => level_club.id}

      response.should redirect_to(edit_admin_level_club_catalog_path(level_club))

      flash[:alert].should == "Please select items"

      level_club.reload.catalog.size.should == 0

    end
  end

  context "remove_item" do
    it "should remove client item from a level club catalog" do
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog, :item => Fabricate(:item, :title => "Item title"))
      level_club.catalog.add([client_item])
      put :remove_item, {:id => level_club.id, :client_item_id => client_item.id}

      response.should redirect_to(admin_level_club_catalog_path(level_club))
      level_club.reload.catalog.size.should == 0
      ClientItem.find(client_item.id).deleted?.should be_false
      flash[:notice].should == "The Item Item title has been removed from the Scheme Level1 Platinum catalog"
    end
  end

end