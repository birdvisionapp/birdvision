require 'spec_helper'

describe PointRangeCalculator do
  before :each do
    @user_scheme = mock(:user_scheme)
    self.extend PointRangeCalculator
  end

  it "should have point_range based on scheme if no other params present" do
    @user_scheme.stub(:minimum_points).and_return(100)
    @user_scheme.stub(:maximum_points).and_return(1000)

    point_range = self.point_range_for(@user_scheme)
    point_range.should == {:min => 100, :max => 1000, :selected_min => 100, :selected_max => 1000}
  end

  it "should have min max in point_range from stats in search results" do
    search_stats = {'min' => 200, 'max' => 2000}
    point_range = self.point_range_for(@user_scheme, search_stats)
    point_range.should == {:min => 200, :max => 2000, :selected_min => 200, :selected_max => 2000}
  end

  it "should have selected min max in point_range from params" do
    search_stats = {'min' => 200.0, 'max' => 2000.0}
    search_params = {'point_range_min' => 300, 'point_range_max' => 1500}
    point_range = self.point_range_for(@user_scheme, search_stats, search_params)
    point_range.should == {:min => 200, :max => 2000, :selected_min => 300, :selected_max => 1500}
  end

  it "should have selected min max  within min max range even if price filter params are outside range" do
    search_stats = {'min' => 200.0, 'max' => 2000.0}
    search_params = {'point_range_min' => 100, 'point_range_max' => 3000}
    point_range = self.point_range_for(@user_scheme, search_stats, search_params)
    point_range.should == {:min => 200, :max => 2000, :selected_min => 200, :selected_max => 2000}
  end

end