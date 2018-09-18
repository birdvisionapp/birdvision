require 'spec_helper'

describe BreadcrumbsHelper do

  context "back to search results link" do
    it "should be shown if user search for a keyword and drills down to a sub category from 'sub categories 'left nav" do
      search = mock("search")
      search.stub(:keyword).and_return("some random keyword")
      search.stub(:category).and_return("some category from sub-categories nav bar")
      can_show_back_link?(search).should == true
    end

    it "should not be shown if only keyword is present and user doesn't drill down to sub category" do
      search = mock("search")
      search.stub_chain(:keyword, :present?).and_return(true)
      search.stub_chain(:category, :present?).and_return(false)
      can_show_back_link?(search).should == false
    end

    it "should not be shown if user only selects sub-category from the all categories drop down" do
      search = mock("search")
      search.stub_chain(:keyword, :present?).and_return(false)
      search.stub_chain(:category, :present?).and_return(true)
      can_show_back_link?(search).should == false
    end
  end

  context "home link" do
    it "should be shown for all other cases except while showing back link" do
      search = mock("search")
      search.stub(:keyword).and_return("some random keyword")
      search.stub(:category).and_return("some category from sub-categories nav bar")
      can_show_home_link?(search).should == false
    end

  end

  context "parent category breadcrumb" do
    it "should be seen as a link if category is present" do
      search = mock("search")
      search.stub_chain(:category, :present?).and_return(true)
      search.stub_chain(:parent_category, :present?).and_return(false)
      search.stub(:keyword)
      is_parent_category_active_in_breadcrumb(search).should == false
    end
    it "should not be seen as a link if parent category is present and category is not present" do
      search = mock("search")
      search.stub_chain(:category, :present?).and_return(false)
      search.stub_chain(:parent_category, :present?).and_return(true)
      search.stub(:keyword)
      is_parent_category_active_in_breadcrumb(search).should == true
    end
  end

  context "sub category breadcrumb" do
    it "should be shown when category is present" do
      search = mock("search")
      search.stub_chain(:category, :present?).and_return(true)
      search.stub(:keyword)
      sub_category_breadcrumb(search).should == true
    end
  end
end

