require 'request_spec_helper'

feature "Static Pages Spec" do
  scenario "about us page should redirect to birdvision.in" do
    visit(root_path)
    within("#footer") do
      page.should have_link("About Us", "http://www.birdvision.in")
    end
  end
  scenario "should hide header components for static pages for logged in user" do
    @user = Fabricate(:user, :full_name => "Ramesh Chopra")
    login_as @user
    [privacy_policy_path, faq_path, terms_and_conditions_path, contact_us_path].each do |static_page_path|
      visit(static_page_path)
      within("#siteHeader") do
        page.should_not have_selector("div.barometer-container")
        page.should_not have_selector("div#searchForm")
        page.should have_content(@user.full_name)
      end
    end
  end
end
