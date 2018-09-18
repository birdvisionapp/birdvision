require 'request_spec_helper'

feature "Catalog Spec" do
  before(:each) do
    @user = Fabricate(:user)
    @client = @user.client
    scheme = Fabricate(:scheme, :single_redemption => true, :client => @client, :name => 'Spring Bonanza Scheme', :levels => %w(level1), :clubs => %w(platinum gold))
    @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => scheme)
    @platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => @client.client_catalog)
    level_club_for(scheme, 'level1', 'platinum').catalog.add([@platinum_item])
    login_as @user
  end

  scenario "should show items belonging to specified level, club" do
    update_level_club(@user_scheme, "level1", nil)

    visit(catalog_path(:id => @user_scheme.applicable_level_clubs.with_club('platinum').first, :scheme_slug => @user_scheme.scheme.slug))

    page.should have_content "Platinum"

    within('.level1-platinum') do
      page.should have_content @platinum_item.title
      find(".not-eligible").should be_true
    end
  end
  scenario "should show button as enabled if user has a club assigned" do
    update_level_club(@user_scheme, "level1", "platinum")

    visit(catalog_path(:id => @user_scheme.applicable_level_clubs.with_club('platinum').first, :scheme_slug => @user_scheme.scheme.slug))

    within('.level1-platinum') do
      page.should have_link("Redeem")
    end
  end

  scenario "should allow user to switch schemes" do
    update_level_club(@user_scheme, "level1", "platinum")
    user_scheme2 = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :name => 'Gold Rush Scheme'))
    update_level_club(user_scheme2, "level1", "platinum")
    login_as @user

    visit(catalogs_path(:scheme_slug => @user_scheme.scheme.slug))

    within("#subHeader") do
      first("#mySchemes a").trigger(:mouseover)
      click_on user_scheme2.scheme.name
      current_url.should include(catalogs_path(:scheme_slug => user_scheme2.scheme.slug))
    end

    within("#subHeader") do
      first("#mySchemes a").trigger(:mouseover)
      click_on "View All Schemes"
      current_url.should include(schemes_path())
    end
  end
  scenario "should not display point range" do
    update_level_club(@user_scheme, "level1", "platinum")

    visit(catalogs_path(:scheme_slug => @user_scheme.scheme.slug))

    page.should_not have_selector('.point-filter')
  end

  scenario "should check carousel item eligibility" do
    @gold_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Gold Canon 1D'), :client_catalog => @client.client_catalog)
    level_club_for(@user_scheme.scheme, 'level1', 'gold').catalog.add([@gold_item])
    update_level_club(@user_scheme, "level1", "gold")

    visit(catalogs_path(:scheme_slug => @user_scheme.scheme.slug))

    within("#clientItemCarousel") do
      all(".item").length.should == 2
      within("#item_#{@gold_item.id}") do
        page.should have_link "Redeem", single_redemption_redemption_path(:scheme_slug => @user_scheme.scheme.slug, :id => @gold_item.id)
      end
      within("#item_#{@platinum_item.id}") do
        find(".not-eligible-container")["disabled"].should be_true
      end
    end
  end
end