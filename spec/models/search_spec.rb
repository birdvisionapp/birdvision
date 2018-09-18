require 'spec_helper'

describe Search do
  #it { should validate_presence_of(:keyword) }


  context "Validation" do

    it "should fail validation if no fields is present" do
      search = Search.new()
      search.valid?.should be_false
      search.errors.first.should == [:search, "atleast one parameter should be present"]
    end

    it "should clear validations if atleast one parameter is provided" do
      search = Search.new(:point_range_min => 10, :point_range_max => 100)
      search.valid?.should be_true
    end

  end

  context "stats_for" do
    it "should" do
      search = Search.new(:point_range_min => 10, :point_range_max => 100)
      stats_search =  search.for_stats(:points)
      stats_search.point_range_max.should be_nil
      stats_search.point_range_min.should be_nil
      stats_search.stats.should == :points
      stats_search.per_page_value.should == 0
    end

  end

  it "should return false for persisted?" do
    Search.new.persisted?.should be_false
  end

  it "should expose params as attributes" do
    search = Search.new(:keyword => 'param')
    search.keyword.should == 'param'
  end

  context "per page" do
    it "should return default value if none set" do
      Search.new.per_page_value.should == Search::DEFAULT_PER_PAGE
    end

    it "should return given value" do
      Search.new(:per_page => 4).per_page_value.should == 4
    end
  end

  context "page" do
    it "should return default value if none set" do
      Search.new.page_value.should == Search::DEFAULT_PAGE
    end

    it "should return given value" do
      Search.new(:page => 3).page_value.should == 3
    end
  end

  context "point_range" do
    it "should return given values" do
      Search.new(:point_range_min => 2, :point_range_max => 3).point_range_value.should == (2..3)
    end

    it "should return nil point_range value if none provided" do
      Search.new.point_range_value.should be_nil
    end
  end
end