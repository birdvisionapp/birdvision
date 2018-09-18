require 'spec_helper'

describe CatalogItem do
  it { should belong_to(:client_item) }
  it { should belong_to(:catalog_owner) }
  it { should allow_mass_assignment_of :client_item }
  it { should be_trailed }

  context "search" do
    it "should reindex associated client item on save" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client)
      client_item = Fabricate(:client_item, :client_catalog => client.client_catalog)

      Sunspot.should_receive(:index!).with(client_item)

      level_club_for(scheme, 'level1', 'platinum').catalog.add([client_item])
    end
  end
end