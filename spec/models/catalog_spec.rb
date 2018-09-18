require 'spec_helper'

describe Catalog do
  let!(:client_item) { Fabricate(:client_item) }
  let!(:level_club) { Fabricate(:level_club) }
  it "should add client items" do
    catalog = level_club.catalog

    catalog.add([client_item])

    catalog.size.should == 1
    catalog.catalog_items.first.client_item.should == client_item
  end

  it "should not add the same client item multiple times" do
    catalog = level_club.catalog
    catalog.add([client_item])
    catalog.add([client_item])

    catalog.size.should == 1
  end

  it "should return active client items sorted by ascending client price" do
    catalog = level_club.catalog
    client_item1 = Fabricate(:client_item, :client_price => 20_000)
    client_item2 = Fabricate(:client_item, :client_price => 10_000)
    client_item3 = Fabricate(:client_item, :client_price => "")
    client_item4 = Fabricate(:client_item, :client_price => nil)
    catalog.add([client_item1, client_item2, client_item3, client_item4])

    catalog.active_client_items.should == [client_item2, client_item1]
  end
end