require 'request_spec_helper'

feature "Catalog Spec" do
  def setup_catalogs(user_scheme)
    @platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => @client.client_catalog)
    @gold_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Gold Canon 1D'), :client_catalog => @client.client_catalog)
    @silver_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Silver Canon 1D'), :client_catalog => @client.client_catalog)
    user_scheme.scheme.client_items = [@platinum_item, @gold_item, @silver_item]
    level_club_for(user_scheme.scheme, 'level2', 'platinum').catalog.add([@platinum_item])
    level_club_for(user_scheme.scheme, 'level2', 'gold').catalog.add([@gold_item])
    level_club_for(user_scheme.scheme, 'level2', 'silver').catalog.add([@silver_item])
  end

  scenario "should show user specific level clubs" do
    @user = Fabricate(:user)
    user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme_3x3, :client => @user.client))
    update_level_club(user_scheme, 'level2', nil)

    @client = @user.client

    login_as @user
    setup_catalogs(user_scheme)

    other_level_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Level1 Canon 1D'), :client_catalog => @client.client_catalog)
    level_club_for(user_scheme.scheme, 'level1', 'silver').catalog.add([other_level_item])

    visit(schemes_path)

    click_on user_scheme.scheme.name

    page.should have_content "Platinum"
    page.should have_content "Gold"
    page.should have_content "Silver"

    within('.level2-platinum') do
      page.should have_content @platinum_item.title
      find(".not-eligible").should be_true
    end
    within('.level2-gold') do
      page.should have_content @gold_item.title
      find(".not-eligible").should be_true
    end
    within('.level2-silver') do
      page.should have_content @silver_item.title
      find(".not-eligible").should be_true
    end

    page.should_not have_content(other_level_item.title)
    page.should_not have_content("Cart")
  end

  scenario "should only show first 3 items per catalog" do
    @user = Fabricate(:user)
    user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme_3x3, :client => @user.client))
    update_level_club(user_scheme, 'level2', nil)

    @client = @user.client

    login_as @user
    setup_catalogs(user_scheme)

    4.times { |i|
      @platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => "Platinum Canon #{i}D"), :client_catalog => @client.client_catalog)
      level_club_for(user_scheme.scheme, 'level2', 'platinum').catalog.add([@platinum_item])
    }

    visit(schemes_path)
    click_on user_scheme.scheme.name
    within('.level2-platinum') do
      all(".not-eligible").size.should == 3
    end

  end

  context "user with club" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme_3x3, :single_redemption => true, :client => @user.client))
      update_level_club(@user_scheme, 'level2', 'gold')
      @client = @user.client

      login_as @user
      setup_catalogs(@user_scheme)
    end

    scenario "should only show users current level club as redeemable" do
      visit(schemes_path)
      click_on @user.user_schemes.first.scheme.name

      within('.platinum-catalog') do
        page.should have_content "You are not eligible for platinum club rewards."
      end
      within('.level2-platinum') do
        page.should have_content @platinum_item.title
        find(".not-eligible").should be_true
      end
      within('.gold-catalog') do
        page.should_not have_content "You are not eligible for gold club rewards."
      end
      within('.level2-gold') do
        page.should have_content @gold_item.title
        page.should have_link("Redeem")
      end
      within('.silver-catalog') do
        page.should_not have_content "You are not eligible for silver club rewards."
      end
      within('.level2-silver') do
        page.should have_content @silver_item.title
        page.should have_link("Redeem")
      end
      page.should_not have_content("Cart")
    end

    scenario "should redirect user to delivery address page when user clicks redeem" do
      visit(schemes_path)
      click_on @user_scheme.scheme.name

      within('.level2-gold') do
        click_link("Redeem")
        current_path.should == new_order_path(:scheme_slug => @user_scheme.scheme.slug)
      end
      within('#siteContent') do
        page.should_not have_content("Total")
      end
    end

    scenario "should show message if user has already redeemed" do

      user_scheme = @user.user_schemes.first
      order = Fabricate(:order, :user => @user)
      Fabricate(:order_item, :client_item => @gold_item, :order => order, :scheme => user_scheme.scheme)

      visit(schemes_path)
      click_on user_scheme.scheme.name
      within('.catalogs') do
        page.should have_content "You have already redeemed from this scheme!"
      end

    end
  end

  context "Future scheme" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user,
                               :scheme => Fabricate(:future_scheme, :client => @user.client))
      update_level_club(@user_scheme, 'level1', "platinum")

      @client = @user.client
      login_as @user
    end

    scenario "should show message if the scheme is not yet active" do
      visit(schemes_path)
      click_on @user_scheme.scheme.name

      within('.catalogs') do
        page.should have_content "This scheme is not yet active!"
      end
    end
  end

  context "Price for Item in a catalog" do
    scenario "should display the right price in points based on the correct client item, when an item is present in two client catalogs" do
      category = Fabricate(:category)
      sub_category = Fabricate(:category, :ancestry => category.id)

      macbook_pro = Fabricate(:macbook_pro, :bvc_price => 1_10_000, :category => sub_category)
      item_supplier = macbook_pro.item_suppliers.first
      item_supplier.mrp = 120000
      item_supplier.channel_price = 80000

      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      emerson_mac = Fabricate(:client_item, :client_catalog => emerson.client_catalog, :item => macbook_pro, :client_price => 1_15_001)
      big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD")
      @user1 = Fabricate(:user, :client => emerson)
      user_scheme1 = Fabricate(:user_scheme, :user => @user1, :scheme => big_bang_dhamaka)
      big_bang_dhamaka.client_items = [emerson_mac]
      level_club_for(big_bang_dhamaka, 'level1', 'platinum').catalog.add([emerson_mac])

      trend_micro = Fabricate(:client, :client_name => "Trend Micro", :points_to_rupee_ratio => 3)
      trend_micro_mac = Fabricate(:client_item, :client_catalog => trend_micro.client_catalog, :item => macbook_pro, :client_price => 1_14_999)
      tm_dhamaka = Fabricate(:scheme, :client => trend_micro, :name => "TMD")
      @user2 = Fabricate(:user, :client => trend_micro)
      user_scheme2 = Fabricate(:user_scheme, :user => @user2, :scheme => tm_dhamaka)

      tm_dhamaka.client_items = [trend_micro_mac]
      level_club_for(tm_dhamaka, 'level1', 'platinum').catalog.add([trend_micro_mac])

      login_as @user1
      visit(catalog_path_for(user_scheme1))
      page.should have_content '2,30,002'

      logout

      login_as @user2
      visit(catalog_path_for(user_scheme2))
      page.should have_content '3,44,997'
    end

  end

  context "categories in categories nav" do
    scenario "should display only categories from which client has the items" do
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      electronics = Fabricate(:category, :title => "Electronics")
      furniture = Fabricate(:category, :title => "Furniture")
      sub_category_mobile = Fabricate(:category, :title => "Mobile", :ancestry => electronics.id)
      sub_category_sofa = Fabricate(:category, :title => "sofa", :ancestry => furniture.id)
      mobile = Fabricate(:item, :title => "mobile", :category => sub_category_mobile)
      client_item = Fabricate(:client_item, :item => mobile, :client_catalog => emerson.client_catalog)
      big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD")
      @user1 = Fabricate(:user, :client => emerson)
      user_scheme = Fabricate(:user_scheme, :user => @user1, :scheme => big_bang_dhamaka)

      big_bang_dhamaka.client_items = [client_item]
      level_club_for(big_bang_dhamaka, 'level1', 'platinum').catalog.add([client_item])

      login_as @user1
      visit(catalog_path_for(user_scheme))
      within ('.global-category-header') do
        all("li").collect(&:text) =~ [sub_category_mobile, sub_category_sofa, furniture, electronics].collect(&:title)
      end
    end
  end

  context "removed client item" do
    scenario "should not show removed client item to participant" do
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      electronics = Fabricate(:category, :title => "Electronics")
      sub_category_mobile = Fabricate(:category, :title => "Mobile", :ancestry => electronics.id)
      mobile = Fabricate(:item, :title => "mobile", :category => sub_category_mobile)
      client_item = Fabricate(:client_item, :item => mobile, :client_catalog => emerson.client_catalog)
      big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD")
      @user1 = Fabricate(:user, :client => emerson)
      user_scheme = Fabricate(:user_scheme, :user => @user1, :scheme => big_bang_dhamaka)

      big_bang_dhamaka.client_items = [client_item]
      level_club_for(big_bang_dhamaka, 'level1', 'platinum').catalog.add([client_item])

      login_as @user1
      visit(catalog_path_for(user_scheme))

      within(".level1-platinum") do
        page.should have_content client_item.item.title
        page.should have_content '18,000'
      end
      logout

      admin_user = Fabricate(:admin_user)
      login_as admin_user, :scope => :admin_user
      visit(admin_master_catalog_index_path)
      click_on 'Emerson'
      within('.client_item') do
        click_on 'Delete'
      end
      within('.alert-success') do
        page.should have_content("The Item mobile has been removed from the Emerson Client Catalog")
      end
      logout

      login_as @user1
      visit(catalog_path_for(user_scheme))
      within(".level1-platinum") do
        page.should_not have_content('mobile')
        page.should_not have_content('18,000')
      end
      within ('.global-category-header') do
        page.should_not have_content electronics.title
        page.should_not have_content sub_category_mobile.title
      end
    end
  end
  context "single redemption participant" do
    let(:client) { Fabricate(:client, :client_name => "Single redemption client") }
    let(:user) { user = Fabricate(:user, :client => client) }
    before(:each) {
      login_as user
    }

    scenario "should display current scheme achievements" do
      past_scheme = Fabricate(:expired_scheme, :single_redemption => true, :name => "single redemption past scheme", :client => client)
      user_scheme = Fabricate(:user_scheme, :scheme => past_scheme, :user => user, :current_achievements => 5_000)
      update_level_club(user_scheme, 'level1', 'platinum')
      Timecop.freeze(Date.new(2015, 10, 2)) do

        visit(catalogs_path(:scheme_slug => past_scheme.slug))
        within ('.total-achievements') do
          page.should have_content "5,000"
        end
      end
    end

    scenario "should not display achievements given user does not have achievements for the current scheme" do
      scheme = Fabricate(:single_redemption_scheme, :name => "single redemption active scheme", :client => client)
      user_scheme = Fabricate(:user_scheme, :scheme => scheme, :user => user, :current_achievements => nil)
      update_level_club(user_scheme, 'level1', 'platinum')

      visit(catalogs_path(:scheme_slug => scheme.slug))
      page.should_not have_content("Total Achievements")
    end

    scenario "should not display point range" do
      scheme = Fabricate(:scheme, :single_redemption => true, :name => "single redemption active scheme", :client => client)
      user_scheme = Fabricate(:user_scheme, :scheme => scheme, :user => user, :current_achievements => nil)
      update_level_club(user_scheme, "level1", "platinum")

      visit(catalogs_path(:scheme_slug => scheme.slug))
      page.should_not have_selector('.point-filter')
    end

    scenario "should check carousel item eligibility" do
      scheme = Fabricate(:scheme, :single_redemption => true, :name => "single redemption active scheme", :client => client, :levels => %w(level1), :clubs => %w(platinum gold))
      user_scheme = Fabricate(:user_scheme, :scheme => scheme, :user => user, :current_achievements => nil)
      @gold_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Gold Canon 1D'), :client_catalog => client.client_catalog)
      level_club_for(user_scheme.scheme, 'level1', 'gold').catalog.add([@gold_item])
      @platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => client.client_catalog)
      level_club_for(scheme, 'level1', 'platinum').catalog.add([@platinum_item])

      update_level_club(user_scheme, "level1", "gold")

      visit(catalogs_path(:scheme_slug => scheme.slug))

      within("#clientItemCarousel") do
        all(".item").length.should == 2
        within("#item_#{@gold_item.id}") do
          page.should have_link "Redeem", single_redemption_redemption_path(:scheme_slug => scheme.slug, :id => @gold_item.id)
        end
        within("#item_#{@platinum_item.id}") do
          find(".not-eligible-container")["disabled"].should be_true
        end
      end
    end
  end
end
