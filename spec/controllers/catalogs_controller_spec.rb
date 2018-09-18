require 'spec_helper'

describe CatalogsController do
  context "routes" do
    it "should route requests correctly" do
      {:get => catalogs_path(:scheme_slug => "some_scheme_slug")}.should route_to("catalogs#index", :scheme_slug => "some_scheme_slug")
      {:get => catalog_path(:scheme_slug => "some_scheme_slug", :id => 23)}.should route_to("catalogs#show", :scheme_slug => "some_scheme_slug", :id => "23")
    end
  end

  context "index" do
    login_user

    let(:scheme) { Fabricate(:scheme, :levels => %w(level1), :clubs => %w(club1 club2), :client => @user.client) }
    let(:user_scheme) { Fabricate(:user_scheme, :user => @user, :scheme => scheme) }

    it "should return catalogs" do
      update_level_club(user_scheme, "level1", nil)
      get :index, :scheme_slug => scheme.slug

      response.should be_ok
      response.should render_template(:index)
      assigns[:catalogs].size.should == 2
      assigns[:user_scheme].should == user_scheme
    end

    it "should redirect to level-club catalog given scheme with single club" do
      scheme = Fabricate(:scheme, :levels => %w(level1 level2), :clubs => %w(club1))
      user_scheme = Fabricate(:user_scheme, :scheme => scheme, :user => @user)
      update_level_club(user_scheme, "level1", "club1")

      get :index, :scheme_slug => scheme.slug

      response.should redirect_to(catalog_path(:scheme_slug => scheme.slug, :id => scheme.level_clubs.first.id))
    end

  end

  context "show" do
    login_user
    before :each do
      @scheme = Fabricate(:scheme, :levels => %w(level1 level2), :clubs => %w(platinum gold), :client => @user.client)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @scheme)
    end

    it "should show all items associated with the catalog" do
      update_level_club(@user_scheme, "level1", "platinum")

      get :show, :id => level_club_for(@scheme, "level1", "platinum").id, :scheme_slug => @user_scheme.scheme.slug

      response.should be_ok
      response.should render_template(:show)
      assigns[:catalogs].size.should == 2
      assigns[:club_catalog].name.should == "Level1-Platinum"
    end

    it "should redirect to catalogs page if user's level does not match'" do
      update_level_club(@user_scheme, "level2", nil)

      get :show, :id => level_club_for(@scheme, 'level1', "platinum").id, :scheme_slug => @user_scheme.scheme.slug

      response.should redirect_to(catalogs_path)
    end

    it "should paginate results" do
      update_level_club(@user_scheme, "level1", "platinum")
      client_item1 = Fabricate.build(:client_item, :client_catalog => @user.client.client_catalog)
      client_item2 = Fabricate.build(:client_item, :client_catalog => @user.client.client_catalog)
      client_items = [client_item1, client_item2]

      ClientItem.should_receive(:page).with("2").and_return(client_items)

      get :show, :page => 2, :scheme_slug => @scheme.slug, :id => @scheme.level_clubs.first

      assigns[:client_items].should == client_items
      assigns[:user_scheme].should == @user_scheme

    end

    it "should set point range based on the level clubs" do
      client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 10_000)
      client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000)
      client_items = [client_item2, client_item1]
      @scheme.catalog.add(client_items)
      level_club_for(@scheme, 'level1', 'gold').catalog.add(client_items)
      update_level_club(@user_scheme, 'level1', 'gold')

      get :index, :scheme_slug => @scheme.slug

      assigns[:point_range].should == {"min" => 50000, "max" => 100000, "selected_min" => 50000, "selected_max" => 100000}
    end
  end
end