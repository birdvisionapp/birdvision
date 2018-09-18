require 'spec_helper'

describe Admin::ItemHelper do
  class DemoClass
    extend Admin::ItemHelper
  end

  it "should return formatted client names for the item" do
    item = Fabricate(:item)
    Fabricate(:client_item, :item => item, :client_catalog => Fabricate(:client, :client_name => "client1").client_catalog)
    Fabricate(:client_item, :item => item, :client_catalog => Fabricate(:client, :client_name => "client2").client_catalog)
    DemoClass.get_client_names_for(item).should == "client1, \nclient2"
    DemoClass.get_client_names_csv_for(item).should == "client1, client2"
  end

  it "client names should not include clients from which its deleted " do
    item = Fabricate(:item)
    Fabricate(:client_item, :item => item, :client_catalog => Fabricate(:client, :client_name => "client1").client_catalog )
    Fabricate(:client_item, :item => item, :client_catalog => Fabricate(:client, :client_name => "client2").client_catalog, :deleted => true)
    DemoClass.get_client_names_for(item).should == "client1"
  end
end