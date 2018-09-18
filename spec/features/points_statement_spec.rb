require 'request_spec_helper'

feature "Points Statement Spec" do
  context "point based" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client, :name => 'My Test Scheme'), :total_points => 5_000, :redeemed_points => 3_000)
      login_as @user
    end    
    context "Points Statement Page" do
      scenario "should show all points transactions for a user" do
        visit(points_summary_path)
        within('.points-summary') do
          page.should have_content "Points Statement"
          page.should have_content "Total Points"
          page.should have_content "Redeemed Points"
          page.should have_content "Remaining Points"
          page.should have_content "My Test Scheme"
          page.should have_content "5,000"
          page.should have_content "3,000"
          page.should have_content "2,000"
        end        
      end
    end
  end
end