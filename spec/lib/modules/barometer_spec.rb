require 'spec_helper'

describe Barometer do
  let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :total_points => 50, :redeemed_points => 10) }
  subject { Barometer.new(user_scheme.user) }
  its(:remaining_points) { should == 40 }
  its(:redeemed_points) { should == 10 }
  its(:percent_redeemed) { should == 20 }
  its(:percent_remaining) { should == 80 }

  it "should indicate remaining percent as 100 if total points = 0" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :total_points => 0, :redeemed_points => 0)
    barometer = Barometer.new(user_scheme.user)
    barometer.percent_remaining.should == 100
    barometer.percent_redeemed.should == 0
  end

end