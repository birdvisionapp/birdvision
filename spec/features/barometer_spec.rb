require 'request_spec_helper'
feature "Barometer Spec" do

  context "Show Barometer" do
    before :each do
      @user = Fabricate(:user)
      @scheme = Fabricate(:scheme)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @scheme, :total_points => 10_00_000, :redeemed_points => 0)
      login_as @user
    end

    scenario "should display barometer only if user belongs to point based schemes" do
      visit(catalog_path_for(@user_scheme))
      within(".barometer-container") do
        page.should have_content("Redeemed : 0")
        page.should have_content("Remaining : 10,00,000")
      end
      within('.total-points') do
        page.should have_content "10,00,000"
      end
    end

    scenario "should update barometer if points are redeemed" do
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      active_scheme = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.today, :redemption_end_date => Date.today + 45.days)
      visit(catalog_path_for(@user_scheme))

      within(".barometer-container") do
        page.should have_content("Redeemed : 0")
        page.should have_content("Remaining : 10,00,000")
      end
      within('.total-points') do
        page.should have_content "10,00,000"
      end

      active_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => active_scheme, :total_points => 10_00_000, :redeemed_points => 2_00_000)
      visit(catalog_path_for(active_user_scheme))

      within(".barometer-container") do
        page.should have_content("Redeemed : 2,00,000")
        page.should have_content("Remaining : 18,00,000")
      end
      within('.total-points') do
        page.should have_content "20,00,000"
      end

    end

    scenario "should display total points redeemable points including carry forwarded points from past schemes" do
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      active_scheme = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.today, :redemption_end_date => Date.today + 45.days)
      past_scheme = Fabricate(:expired_scheme, :client => emerson, :name => "SBD")

      active_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => active_scheme, :total_points => 10_00_000, :redeemed_points => 2_00_000)
      Fabricate(:user_scheme, :user => @user, :scheme => past_scheme, :total_points => 10_00_000, :redeemed_points => 4_00_000)

      visit(catalog_path_for(active_user_scheme))
      within(".barometer-container") do
        page.should have_content("Redeemed : 6,00,000")
        page.should have_content("Remaining : 24,00,000")
      end
      within('.total-points') do
        page.should have_content "30,00,000"
      end
    end
  end

  context "Hide Barometer" do
    before :each do
      single_redemption_scheme = Fabricate(:scheme, :single_redemption => true)
      @user = Fabricate(:user, :client => single_redemption_scheme.client)
      Fabricate(:user_scheme, :user => @user, :scheme => single_redemption_scheme)
      login_as @user
    end

    scenario "should hide barometer on schemes page" do
      visit(schemes_path)
      page.should_not have_content("Redeemed : ")
      page.should_not have_content("Remaining : ")
    end
  end
end