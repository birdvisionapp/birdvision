require 'spec_helper'

describe AverageMarginCalculator do
  context "average base margin" do
    before :each do
      @item1 = Fabricate(:item)
      Fabricate(:item)
      Fabricate(:item)
      Fabricate(:item)
      Fabricate(:item)
      self.extend AverageMarginCalculator
    end

    def items
      Item.joins(:preferred_supplier)
    end

    it "should calculate bvc average margin" do
      self.calculate_bvc_margin(items).should == 25.0
    end

    it "should ignore items in average calculation if one of the prices is not set" do
      @item1.update_attribute(:bvc_price, 9000)
      self.calculate_bvc_margin(items).should == 22.5
      @item1.update_attribute(:bvc_price, 0)
      self.calculate_bvc_margin(items).should == 25.0
    end

    it "should return zero average if all base prices are set to 0" do
      Item.update_all("bvc_price = 0")
      self.calculate_bvc_margin(items).should == 0.0
    end
  end
  context "average client margin" do
    before :each do
      @client = Fabricate(:client)
      @client_item = Fabricate(:client_item, :client_catalog => @client.client_catalog, :client_price => 10_000)
      @client_item2 = Fabricate(:client_item, :client_catalog => @client.client_catalog)
      @client_item3 = Fabricate(:client_item, :client_catalog => @client.client_catalog)
      self.extend AverageMarginCalculator
    end

    it "should calculate client margin for client items" do
      self.client_margin_for_client_items(@client.client_items).should == 16.67
      @client_item.update_attributes!(:client_price => nil)
      self.client_margin_for_client_items(@client.client_items).should == 12.5

    end

    it "should calculate client margin for catalog items" do
      scheme = Fabricate(:scheme, :client => @client_item.client)
      catalog_item = Fabricate(:catalog_item, :client_item => @client_item, :catalog_owner => scheme)
      Fabricate(:catalog_item, :client_item => @client_item2, :catalog_owner => scheme)
      Fabricate(:catalog_item, :client_item => @client_item3, :catalog_owner => scheme)
      self.client_margin_for_catalog_items(scheme.catalog_items).should == 16.67
    end
  end
end