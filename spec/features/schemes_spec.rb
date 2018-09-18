require 'request_spec_helper'

feature "Schemes" do
  context "existing schemes" do

    before :each do
      Timecop.travel(2015, 10, 2)
      @user = Fabricate(:user)
      @active_scheme = Fabricate(:scheme, :name => 'Diwali Dhamaka Active', :start_date => Date.new(2015, 9, 1),
                                 :end_date => Date.new(2015, 9, 25),
                                 :redemption_start_date => Date.new(2015, 10, 1),
                                 :redemption_end_date => Date.new(2015, 10, 20), :client => @user.client)

      @single_redemption_scheme = Fabricate(:scheme, :name => 'Single redemption', :start_date => Date.new(2015, 9, 1),
                                            :end_date => Date.new(2015, 9, 25), :single_redemption => true,
                                            :redemption_start_date => Date.new(2015, 10, 1),
                                            :redemption_end_date => Date.new(2015, 10, 20), :client => @user.client)
      @future_scheme = Fabricate(:scheme, :name => 'Diwali Dhamaka Future', :start_date => Date.new(2015, 10, 1),
                                 :end_date => Date.new(2015, 10, 25),
                                 :redemption_start_date => Date.new(2015, 11, 1),
                                 :redemption_end_date => Date.new(2015, 11, 20), :client => @user.client)
      @past_scheme = Fabricate(:scheme, :name => 'Diwali Dhamaka Expired', :start_date => Date.new(2015, 8, 1),
                               :end_date => Date.new(2015, 8, 25),
                               :redemption_start_date => Date.new(2015, 9, 1),
                               :redemption_end_date => Date.new(2015, 9, 20), :client => @user.client)
      @scheme_not_yet_started = Fabricate(:scheme, :start_date => Date.new(2016, 8, 1),
                                          :end_date => Date.new(2016, 8, 25),
                                          :redemption_start_date => Date.new(2016, 9, 1),
                                          :redemption_end_date => Date.new(2016, 9, 20), :client => @user.client)

      Fabricate(:user_scheme, :user => @user, :scheme => @active_scheme, :total_points => 50_000)
      Fabricate(:user_scheme, :user => @user, :scheme => @future_scheme, :total_points => 20_000)
      Fabricate(:user_scheme, :user => @user, :scheme => @past_scheme, :total_points => 10_000)
      Fabricate(:user_scheme, :user => @user, :scheme => @single_redemption_scheme, :total_points => 10_000)

      login_as @user

    end
    after :each do
      Timecop.return
    end

    scenario "should show active participant schemes" do

      visit(schemes_path)

      within("#ready_for_redemption") do
        within("#scheme_#{@active_scheme.id}") do
          page.should have_content("Diwali Dhamaka Active")
          page.should have_content("October 1st, 2015 to October 20th, 2015")
          page.should have_content("50,000 points earned")
          page.should have_content("You can redeem these rewards until October 20th, 2015")
          page.should have_link('', :href => catalog_path_for(@user.user_schemes.first))
          page.should_not have_css('.disabled-scheme')
          find(".hero_image").find("img[alt=Hero_bbd]")['src'].should include(@active_scheme.hero_image.url(:original, false))
          page.should have_content("Redeem Rewards")
        end

        within("#scheme_#{@single_redemption_scheme.id}") do
          page.should have_content("Single redemption")
          page.should_not have_content("points earned")
        end

      end
    end

    scenario "should show previously future scheme as active from scheme redemption start date" do
      Timecop.travel(2015, 11, 2)

      visit(schemes_path)

      within("#ready_for_redemption") do
        page.should have_content("Diwali Dhamaka Future")
        page.should have_content("20,000 points earned")
        page.should have_content("November 1st, 2015 to November 20th, 2015")
        page.should have_content("You can redeem these rewards until November 20th, 2015")
        find(".hero_image").find("img[alt=Hero_bbd]")['src'].should include(@future_scheme.hero_image.url(:original, false))
        page.should have_content("Redeem Rewards")
      end

      Timecop.return
    end

    scenario "should show future schemes" do

      visit(schemes_path)

      within("#upcoming") do
        page.should have_content("Diwali Dhamaka Future")
        page.should have_content("October 1st, 2015 to November 20th, 2015")
        page.should have_content("20,000 points earned")
        page.should have_content("You can redeem these rewards from November 1st, 2015")
        page.should have_content("View Rewards")
      end
    end

    scenario "should show expired schemes" do

      visit(schemes_path)

      within("#past") do
        page.should have_content("Diwali Dhamaka Expired")
        page.should have_content("10,000 points earned")
        page.should have_content("The Redemption period for this scheme is over")
        page.should_not have_link('', :href => catalog_path_for(@user.user_schemes.first))
        page.should have_css(".disabled-scheme")
      end
    end

  end

  context "no schemes" do
    before :each do
      scheme = Fabricate(:not_yet_started_scheme)
      user = Fabricate(:user)
      Fabricate(:user_scheme, :user => user, :scheme => scheme)
      login_as user
    end

    scenario "should indicate there are no active schemes" do
      visit(schemes_path)
      within("#siteContent") {
        page.should have_content("None of your schemes are currently active")
      }
    end
  end
end
