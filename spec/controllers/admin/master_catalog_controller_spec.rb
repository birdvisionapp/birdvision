require 'spec_helper'

describe Admin::MasterCatalogController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => admin_master_catalog_index_path}.should route_to('admin/master_catalog#index')
    end
  end

  context "browse draft items" do

    it "should show master catalog sorted by creation time" do
      item1 = Fabricate(:item)
      item2 = Fabricate(:blue_sofa)

      get :index
      assigns[:average_bvc_margin].should == 12.5
      assigns[:items].should == [item2, item1]
      response.should be_success
    end

    it "should show average base margin on result set of applied filter" do
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1, :bvc_price => 27_000)
      Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart, :is_preferred => true)


      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2, :bvc_price => 30_000)
      Fabricate(:item_supplier, :item => red_table, :mrp => 35_000, :channel_price => 20_000, :supplier => infibeam, :is_preferred => true)

      get :index, :q => {:preferred_supplier_mrp_gteq => 31000, :preferred_supplier_mrp_lteq => 32000}
      assigns[:average_bvc_margin].should == 50
      assigns[:items].should == [s2]
      response.should be_success
    end
  end

  context "download csv" do

    it "should download csv for filtered results" do
      item1 = Fabricate(:item)
      item2 = Fabricate(:blue_sofa)

      get :index, :q => {:title_cont => item2.title}, :format => :csv

      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "Blue Sofa"
      response.body.should_not include "Nikon Point and Shoot Camera"
    end
  end
end
