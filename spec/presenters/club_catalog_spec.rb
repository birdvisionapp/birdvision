require 'spec_helper'

describe ClubCatalog do
  before(:each) do
    @user_scheme = Fabricate(:single_redemption_user_scheme, :scheme => Fabricate(:scheme_3x3, :single_redemption => true))
    update_level_club(@user_scheme, "level2", "gold")
    @level2_gold = level_club_for(@user_scheme.scheme, 'level2', 'gold')
    @level2_platinum = level_club_for(@user_scheme.scheme, 'level2', 'platinum')
  end

  it "should identify if user is not eligible for given club catalog" do
    club_catalog = ClubCatalog.new(@user_scheme, @level2_platinum)
    club_catalog.ineligible?.should be_false
  end

  it "should identify if user is eligible for given club catalog" do
    club_catalog = ClubCatalog.new(@user_scheme, @level2_gold)
    club_catalog.ineligible?.should be_true
  end

  it "should return items" do
    client_items = [Fabricate.build(:client_item)]
    @level2_gold.stub_chain(:catalog, :active_client_items).and_return(client_items)

    club_catalog = ClubCatalog.new(@user_scheme, @level2_gold)
    club_catalog.items.should == client_items
  end

  it "should return featured items" do
    client_items = 4.times.collect { Fabricate.build(:client_item) }
    @level2_gold.stub_chain(:catalog, :active_client_items).and_return(client_items)

    club_catalog = ClubCatalog.new(@user_scheme, @level2_gold)
    club_catalog.featured_items.size.should == 3
    club_catalog.featured_items.should == client_items.first(3)
  end
end