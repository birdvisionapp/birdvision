require 'request_spec_helper'

feature "Search Spec" do
  before :each do
    @user = Fabricate(:user)
    login_as @user
    Sunspot.remove_all!
  end

  let(:camera_category) { Fabricate(:category, :title => 'Camera') }
  let(:canon) { Fabricate(:sub_category_canon, :title => "Canon", :ancestry => camera_category.id) }
  let(:accessories_category) { Fabricate(:category, :title => 'Accessories') }
  let(:keyboard) { Fabricate(:sub_category_keyboard, :title => "Keyboard", :ancestry => accessories_category.id) }
  let(:tripod) { Fabricate(:sub_category_tripod, :title => "Tripod", :ancestry => accessories_category.id) }
  let(:plastic) { Fabricate(:category, :title => "plastic") }

  context "results" do
    before(:each) do
      client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000, :item => Fabricate(:item, :title => 'Canon Powershot Sx150', :description => "black camera", :category => canon))
      client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 10_000, :item => Fabricate(:item, :title => 'Canon EOS 550D', :description => "black camera", :category => canon))
      client_item3 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => 'Dell Keyboard', :description => "black keyboard", :category => keyboard))
      client_item4 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => 'Canon tripod', :category => tripod))

      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      scheme = user_scheme.scheme
      scheme.client_items = [client_item1, client_item2, client_item3, client_item4]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all
      visit(catalog_path_for(user_scheme))
    end

    scenario "should display search results" do
      search_with 'Canon'
      result_should_contain 'Canon Powershot Sx150', 'Canon EOS 550D'

    end

    scenario "should show only categories from which client has items in the categories nav in search results" do
      sub_category_that_does_not_belong_to_the_client = Fabricate(:sub_category_plastic, :ancestry => plastic.id)
      client_item5 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000,
                               :item => Fabricate(:item, :title => 'Canon', :description => "black camera", :category => sub_category_that_does_not_belong_to_the_client))
      search_with 'Canon'

      within ('.search-result-category-list') do
        page.should have_button("Canon (2)")
        page.should have_button("Tripod (1)")
        page.should_not have_content sub_category_that_does_not_belong_to_the_client.title
      end
    end


    scenario "should search by keyword then filter by category" do
      search_with 'Canon'

      click_on('Canon (2)')

      result_should_contain 'Canon Powershot Sx150', 'Canon EOS 550D'
      result_should_not_contain 'Canon tripod'
    end

    scenario "should search by keyword then filter by category then filter by points" do
      search_with 'Canon'

      click_on('Canon (2)')
      filter_by_point_range 70_000, 1_00_000
      result_should_contain 'Canon EOS 550D'
      result_should_not_contain 'Canon Powershot Sx150'
    end
  end

  context "filter by categories" do
    before(:each) do
      client_item1 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Canon Powershot Sx150', :category => canon), :client_catalog => @user.client.client_catalog)
      client_item2 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Canon EOS 550D', :category => canon), :client_catalog => @user.client.client_catalog)
      client_item3 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Canon tripod', :category => tripod), :client_catalog => @user.client.client_catalog)
      client_item4 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Keyboard', :category => keyboard), :client_catalog => @user.client.client_catalog)
      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      scheme = user_scheme.scheme
      scheme.client_items = [client_item1, client_item2, client_item3, client_item4]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)

      Sunspot.index! ClientItem.all
      visit(catalog_path_for(user_scheme))
    end


    scenario "should display all applicable categories and all categories count" do
      search_with 'Canon'

      within(".search-result-category-list") do
        page.should have_button("Canon (2)")
        page.should have_button("Tripod (1)")
        page.should have_content("Sub Categories")
      end
    end

    scenario "should disable category filter when only one category is present" do
      search_with 'Keyboard'

      within(".search-result-category-list") do
        page.should_not have_button("Keyboard (1)")
        page.should have_content("Keyboard (1)")
      end
    end
  end

  context "global category drop down" do
    before(:each) do
      camera_sub_category = Fabricate(:sub_category_sofa, :ancestry => camera_category.id, :title => "camera_sub")
      accessories_sub_category = Fabricate(:sub_category_sofa, :ancestry => accessories_category.id, :title => "accessories_sub")
      client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000, :item => Fabricate(:item, :title => 'Canon Powershot Sx150', :description => "black camera", :category => camera_sub_category))
      client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 10_000, :item => Fabricate(:item, :title => 'Canon EOS 550D', :description => "black camera", :category => camera_sub_category))
      client_item3 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => 'Keyboard', :description => "black keyboard", :category => accessories_sub_category))
      client_item4 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => 'Canon tripod', :category => tripod))
      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      scheme = user_scheme.scheme
      scheme.client_items = [client_item1, client_item2, client_item3, client_item4]
      level_club_for(scheme, 'level1', 'platinum').catalog.add(scheme.client_items)
      Sunspot.index! ClientItem.all
      visit(catalog_path_for(user_scheme))
    end

    scenario "should filter by category when a category is selected from global category drop down" do
      find(".global-category-list").find(".category-list").first(:button, "camera_sub").click
      within ".breadcrumb" do
        page.should have_link "Home", catalog_path_for(@user.user_schemes.first)
        page.should have_content "Camera"
        page.should have_content "camera_sub"
      end
      result_should_contain 'Canon EOS 550D', 'Canon Powershot Sx150'
      result_should_not_contain 'Canon tripod', 'Keyboard'
    end

    scenario "should filter by category when a category is selected from global category drop down" do
      within(".global-category-list") do
        click_on "Accessories"
      end
      result_should_contain 'Keyboard', 'Canon tripod'
      result_should_not_contain 'Canon Powershot Sx150', 'Canon EOS 550D'
    end
  end

  context "point range" do
    before(:each) do
      category = Fabricate(:category)
      sub_category = Fabricate(:category, :ancestry => category.id)
      client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000, :item => Fabricate(:item, :title => 'Canon Powershot Sx150', :category => sub_category))
      client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 10_000, :item => Fabricate(:item, :title => 'Canon EOS 550D', :category => sub_category))
      client_item3 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 15_000, :item => Fabricate(:item, :title => 'Canon EOS 60D', :category => sub_category))
      client_item4 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => 'Samsung 46ES Television', :category => sub_category))
      costlier_item_in_other_level = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 90_000, :item => Fabricate(:item, :title => 'Panasonic Television', :category => sub_category))
      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client, :levels => %w(level1 level2), :clubs => %w(platinum)))
      user_scheme.scheme.client_items = [client_item1, client_item2, client_item3, client_item4]
      level_club_for(user_scheme.scheme, 'level1', 'platinum').catalog.add(user_scheme.scheme.client_items)
      level_club_for(user_scheme.scheme, 'level2', 'platinum').catalog.add([costlier_item_in_other_level])

      Sunspot.index! ClientItem.all
    end

    scenario "should prefill point range by default with min and max of all items" do
      visit(catalog_path_for(@user.user_schemes.first))


      assert_for_point_range 50_000, 2_00_000
    end

    scenario "should display applicable range values based on matching items" do
      visit(search_catalog_path({:search => {:keyword => 'Canon'}, :scheme_slug => @user.user_schemes.first.scheme.slug}))

      assert_for_point_range 50_000, 1_50_000
    end

    scenario "should filter results by point range" do
      visit(search_catalog_path({:search => {:keyword => 'Canon'}, :scheme_slug => @user.user_schemes.first.scheme.slug}))
      page.should have_content("Canon Powershot Sx150")

      filter_by_point_range 80_000, 1_50_000
      result_should_not_contain "Canon Powershot Sx150"
      result_should_contain "Canon EOS 550D", "Canon EOS 60D"
      assert_for_point_range 80_000, 1_50_000

      filter_by_point_range(50_000, 1_20_000)
      result_should_not_contain "Canon EOS 60D"
      result_should_contain "Canon Powershot Sx150", "Canon EOS 550D"
      assert_for_point_range(50_000, 1_20_000)
    end

    context "hide point range" do
      scenario "if only one item in category as price range is not possible" do
        visit(search_catalog_path({:search => {:keyword => 'Samsung'}, :scheme_slug => @user.user_schemes.first.scheme.slug}))
        page.should_not have_selector('.point-filter')
      end

      scenario "for a single redemption scheme" do
        user_scheme = Fabricate(:single_redemption_user_scheme, :user => @user)
        visit(search_catalog_path({:search => {:keyword => 'Samsung'}, :scheme_slug => user_scheme.scheme.slug}))
        page.should_not have_selector('.point-filter')
      end
    end

  end

  context "drill down search results" do

    before :each do
      @furniture= Fabricate(:category, :title => "furniture")
      @sofa = Fabricate(:category, :title => "sofa", :ancestry => @furniture.id)
      @home_appliances = Fabricate(:category, :title => "Home Appliances")
      @ac = Fabricate(:category, :title => "AC", :ancestry => @home_appliances.id)
      @refrigerator = Fabricate(:category, :title => "Refrigerator", :ancestry => @home_appliances.id)
      @client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000, :item => Fabricate(:item, :title => 'Arwin AC', :category => @ac))
      @client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 10_000, :item => Fabricate(:item, :title => 'Voltas AC', :category => @ac))
      @client_item3 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 15_000, :item => Fabricate(:item, :title => 'black fridge', :category => @refrigerator))
      @client_item4 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => 'Whirlpool Refrigerator', :category => @refrigerator))
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      @user_scheme.scheme.client_items = [@client_item1, @client_item2, @client_item3, @client_item4]
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add(@user_scheme.scheme.client_items)
    end
    scenario "should allow drill down for searching" do
      Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => 'Red Sofa', :category => @sofa))

      Sunspot.index! ClientItem.all
      visit(catalog_path_for(@user_scheme))

      within(".global-category-list") do
        click_on "Home Appliances"
      end
      within ".breadcrumb" do
        page.should have_link "Home", catalog_path_for(@user_scheme)
        page.should have_content "Home Appliances"
      end
      result_should_contain 'Arwin AC', 'Voltas AC', 'black fridge', 'Whirlpool Refrigerator'
      result_should_not_contain 'Red Sofa'
      search_with "ac"
      result_should_contain 'Arwin AC', 'Voltas AC', 'black fridge'
      within('.search-result-category-list') do
        click_on 'AC (2)'
      end
      within ".breadcrumb" do
        page.should have_button "Back to search results for \"ac\""
      end
      click_on 'Back to search results for "ac"'
      result_should_contain 'Arwin AC', 'Voltas AC', 'black fridge'
      result_should_not_contain 'Red Sofa'
    end

    scenario "should search for keyword in global and not scoped to current result" do
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 20_000, :item => Fabricate(:item, :title => 'black Whirlpool Refrigerator'))
      @user_scheme.scheme.client_items = [@client_item1, @client_item2, @client_item3, @client_item4, client_item]
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add(@user_scheme.scheme.client_items)

      Sunspot.index! ClientItem.all
      visit(catalog_path_for(@user_scheme))
      within(".global-category-list") do
        click_on "Home Appliances"
      end
      fill_in("search_keyword", :with => 'ac')
      find("#searchForm .btn").click
      result_should_contain 'Arwin AC', 'black fridge', 'Voltas AC', 'black Whirlpool Refrigerator'
      result_should_not_contain 'Red Sofa'
    end

    scenario "should filter results inside the current result set and not global" do
      fridge1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 4_000,
                          :item => Fabricate(:item, :title => 'black leather sofa', :category => @sofa))
      fridge2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 5_000,
                          :item => Fabricate(:item, :title => 'white leather sofa', :category => @sofa))
      @user_scheme.scheme.client_items+=[fridge1, fridge2]
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add(@user_scheme.scheme.client_items)
      Sunspot.index! ClientItem.all

      visit(catalog_path_for(@user_scheme))

      within(".global-category-list") do
        click_on "furniture"
      end
      filter_by_point_range 4_000, 1_00_000
      result_should_not_contain 'Arwin AC', 'Voltas AC', 'Whirlpool Refrigerator', 'black fridge'
      result_should_contain 'white leather sofa', 'black leather sofa'
    end

    scenario "should retain keyword even if there are no search results" do
      visit(catalog_path_for(@user_scheme))
      search_with "ac"
      filter_by_point_range 4_000, 10_000
      filter_by_point_range 50_000, 2_00_000
      result_should_contain 'Arwin AC', 'Voltas AC', 'black fridge'
      result_should_not_contain 'Whirlpool Refrigerator'
    end
  end
end

def search_with keyword
  visit(catalog_path_for(@user.user_schemes.first))

  fill_in("search_keyword", :with => keyword)
  find("#searchForm .btn").click
end

def assert_for_point_range min, max
  within(".point-filter") {
    find_field("search_point_range_min").value.should == min.to_s
    find_field("search_point_range_max").value.should == max.to_s
  }
end

def filter_by_point_range min, max
  within(".point-filter") {
    fill_in("search_point_range_min", :with => min)
    fill_in("search_point_range_max", :with => max)

    click_on(">>")
  }
end

def add_to_level_catalog_of client, level, item
  go_to_level_catalog(client, level)
  click_on "Add Items"
  find(:checkbox, "#batch_action_item_#{item.id}").set(true)
  click_on "Add To Catalog"
end

def go_to_level_catalog(client, level)
  visit(admin_draft_items_path)
  click_on client.client_name
  click_on level
end

def remove_from_level_catalog_of client, level, item
  go_to_level_catalog(client, level)
  within ("#client_item_#{item.id}") do
    click_on "Delete"
  end
end


def result_should_not_contain(*item_names)
  within("#searchResults") do
    item_names.each do |item_name|
      page.should_not have_link(item_name)
    end
  end
end

def result_should_contain(*item_names)
  within("#searchResults") do
    item_names.each do |item_name|
      page.should have_link(item_name)
    end
  end
end