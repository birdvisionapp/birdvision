require 'spec_helper'

describe Admin::CategoriesController do
  login_admin

  context "Browse categories" do

    it "should display all the categories" do
      mobile = Fabricate(:category, :title => "mobile")
      home_appliances = Fabricate(:category, :title => "Home appliances")
      home_utilities = Fabricate(:category, :title => "home utilities")
      furniture = Fabricate(:category, :title => "furniture")
      sub_category = Fabricate(:sub_category_sofa, :ancestry => furniture.id)

      get :index

      assigns[:main_categories].should == [furniture, home_appliances,home_utilities,mobile]
      assigns[:sub_categories].should == [sub_category]
      response.should be_success
    end
  end
end