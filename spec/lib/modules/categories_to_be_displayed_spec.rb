require 'spec_helper'

describe CategoriesToBeDisplayed do
  context "categories" do
    before :each do
      self.extend CategoriesToBeDisplayed
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      @electronics = Fabricate(:category, :title => "Electronics")
      @sub_category_mobile = Fabricate(:category, :title => "Mobile", :ancestry => @electronics.id)
      mobile = Fabricate(:item, :title => "mobile", :category => @sub_category_mobile)
      mobile_client_item = Fabricate(:client_item, :item => mobile, :client_catalog => emerson.client_catalog)
      @big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD")
      @big_bang_dhamaka.client_items = [mobile_client_item]
      level_club_for(@big_bang_dhamaka, 'level1', 'platinum').catalog.add([mobile_client_item])
    end

    it "should return only categories from which the client has items in his catalog for a scheme" do
      get_categories_for(@big_bang_dhamaka.level_clubs).should == [@sub_category_mobile]
    end

    it "should return parent categories for applicable sub categories" do
      get_parent_categories_for(@big_bang_dhamaka.level_clubs).should == [@electronics]
    end
  end
end