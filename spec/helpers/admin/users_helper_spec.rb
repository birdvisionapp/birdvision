require 'spec_helper'

describe Admin::UsersHelper do
  class DemoClass
    extend Admin::UsersHelper

    def deliver

    end
  end

  it "should send notification to users" do
    user_ids = [1, 2, 3, 4]
    User.should_receive(:generate_activation_token_for).exactly(4).times
    UserNotifier.should_receive(:notify_activation).exactly(4).times
    DemoClass.email_password_reset_instructions_to user_ids
  end

  context "points_per_scheme" do
    include ViewsHelper
    it "should return points per scheme for a user in formatted string" do
      scheme1 = Fabricate(:scheme, :name => "Scheme 1", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow)
      scheme2 = Fabricate(:scheme, :name => "Scheme 2", :redemption_start_date => Date.today + 10.days, :redemption_end_date => Date.today + 20.days)
      user = Fabricate(:user)
      Fabricate(:user_scheme, :scheme => scheme1, :user => user, :total_points => 10_000)
      Fabricate(:user_scheme, :scheme => scheme2, :user => user, :total_points => 20_000)
      points_per_scheme(user.reload).should == "Scheme 1 (10,000)<br/>Scheme 2 (20,000)"
      points_per_scheme_csv(user.reload).should == "Scheme 1 (10000), Scheme 2 (20000)"
    end
  end
end