# encoding: utf-8
require 'request_spec_helper'

feature "Client Items" do
  context "item details" do
    before :each do
      @user = Fabricate(:user)
      @scheme = Fabricate(:scheme, :client => @user.client)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @scheme)
      login_as @user
    end
    scenario "should show client item details" do
      category = Fabricate(:category)
      sub_category = Fabricate(:category, :ancestry => category.id)
      macbook_pro = Fabricate(:macbook_pro, :bvc_price => 1_10_000, :category => sub_category)
      macbook_pro.item_suppliers << Fabricate(:item_supplier, :mrp => 1_20_000, :channel_price => 80_000)
      emerson_mac = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => macbook_pro,
                              :client_price => 1_15_001)
      @scheme.client_items = [emerson_mac]
      level_club_for(@scheme, 'level1', 'platinum').catalog.add([emerson_mac])

      visit(client_item_path(:slug => emerson_mac, :scheme_slug => @scheme.slug))

      page.should have_content macbook_pro.title
      page.should have_content macbook_pro.description
      page.should have_content macbook_pro.specification
      page.should have_content '11,50,010'
      page.should have_link("Add to cart", add_to_cart_path(:id => macbook_pro.id, :scheme_slug => @scheme.slug))

      within('.global-category-header') do
        all("li").collect(&:text).should =~ [category.title, sub_category.title]
      end
    end

    scenario "should not show filter by points" do
      client_item = Fabricate(:client_item)

      visit(client_item_path(:slug => client_item, :scheme_slug => @scheme.slug))

      page.should_not have_selector('.point-filter')
    end
  end

  context "breadcrumbs" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      @electronics = Fabricate(:category)
      @furniture = Fabricate(:category)
      @laptop = Fabricate(:category, :ancestry => @electronics.id)
      @sofa = Fabricate(:category, :ancestry => @furniture.id)
      @macbook_pro = Fabricate(:macbook_pro, :bvc_price => 1_10_000, :category => @laptop)
      @red_sofa = Fabricate(:blue_sofa, :category => @sofa)
      @emerson_mac = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => @macbook_pro,
                               :client_price => 1_15_001)
      @emerson_sofa = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => @red_sofa)
      @macbook_pro.item_suppliers << Fabricate(:item_supplier, :mrp => 1_20_000, :channel_price => 80_000)
      @red_sofa.item_suppliers << Fabricate(:item_supplier, :mrp => 1_20_000, :channel_price => 80_000)
      @user_scheme.scheme.client_items = [@emerson_mac, @emerson_sofa]
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([@emerson_mac, @emerson_sofa])
      login_as @user
    end

    it "should take to catalog when clicked on home" do
      visit(client_item_path(:slug => @emerson_mac, :scheme_slug => @user.user_schemes.first.scheme.slug))
      within(".item-category-hierarchy") do
        click_on "Home"
      end
      page.should have_content @macbook_pro.title
      page.should have_content @red_sofa.title
    end

    it "should take to category landing page when clicked on parent category in item breadcrumb" do
      visit(client_item_path(:slug => @emerson_mac, :scheme_slug => @user.user_schemes.first.scheme.slug))
      within(".item-category-hierarchy") do
        click_on @electronics.title
      end
      page.should have_content @macbook_pro.title
      page.should_not have_content @red_sofa.title
    end

    it "should take to search by sub category page when clicked on category of item in breadcrumb" do
      visit(client_item_path(:slug => @emerson_mac, :scheme_slug => @user.user_schemes.first.scheme.slug))
      within(".item-category-hierarchy") do
        click_on @laptop.title
      end
      page.should have_content @macbook_pro.title
      page.should_not have_content @red_sofa.title
    end
  end
  context "single redemption" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :single_redemption => true, :client => @user.client))
      @client = @user.client
      @client.update_attributes!(:points_to_rupee_ratio => 1)
      electronics = Fabricate(:category, :title => "Electronics")
      sub_category_electronics = Fabricate(:category, :title => "tv", :ancestry => electronics.id)

      @platinum_item = Fabricate(:client_item, :client_price => 600, :item => Fabricate(:item, :title => 'Platinum Canon 1D', :category => sub_category_electronics), :client_catalog => @client.client_catalog)
      @user_scheme.scheme.catalog.add([@platinum_item])
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([@platinum_item])

      login_as @user
    end

    scenario "should show client item details" do
      update_level_club(@user_scheme, "level1", nil)

      visit(client_item_path(:slug => @platinum_item, :scheme_slug => @user_scheme.scheme.slug))

      page.should have_content @platinum_item.title
      page.should have_content @platinum_item.item.description
      page.should_not have_content '600'
      within(".add-to-cart") {
        find(".not-eligible-container")["disabled"].should be_true
      }
    end

    scenario "should enable button for users with club" do
      update_level_club(@user_scheme, "level1", "platinum")

      visit(client_item_path(:slug => @platinum_item, :scheme_slug => @user_scheme.scheme.slug))

      within(".add-to-cart") {
        find(".btn-info")["disabled"].should be_false
      }
    end

  end
end