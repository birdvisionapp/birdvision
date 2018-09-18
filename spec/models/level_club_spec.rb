require 'spec_helper'

describe LevelClub do
  it { should validate_presence_of(:level) }
  it { should validate_presence_of(:club) }
  it { should validate_presence_of(:scheme) }

  it { should have_many(:catalog_items) }
  it { should belong_to(:scheme) }

  it { should allow_mass_assignment_of(:level) }
  it { should allow_mass_assignment_of(:club) }
  it { should allow_mass_assignment_of(:scheme) }

  it "name should indicate level, club" do
    Fabricate.build(:level_club, :level_name => 'Level1', :club_name => 'Platinum').name.should == "Level1-Platinum"
  end

  it "should persist catalog changes" do
    client = Fabricate(:client)
    scheme = Fabricate(:scheme, :client => client)
    client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
    level_club = Fabricate(:level_club, :scheme => scheme)

    level_club.catalog.add([client_item1])
    level_club.catalog.size.should == 1

    LevelClub.find(level_club.id).catalog.size.should == 1
  end

  it "should remove catalog item from level catalog" do
    client = Fabricate(:client)
    scheme = Fabricate(:scheme, :client => client)
    client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
    level_club = Fabricate(:level_club, :scheme => scheme)

    level_club.catalog.add([client_item1])
    level_club.remove(client_item1)
    level_club.reload.catalog_items.size.should == 0
  end

  it "should not allow adding a client item, if item is present in another club catalog having same level and same scheme" do
    client = Fabricate(:client)
    scheme1 = Fabricate(:scheme, :name => "scheme1", :client => client)

    client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
    level_club1 = Fabricate(:level_club, :scheme => scheme1)
    level_club1.catalog.add([client_item1])

    level_club2 = Fabricate(:level_club, :level => level_club1.level, :club_name => "silver", :scheme => scheme1)
    level_club2.can_add?([client_item1]).should be_false
  end

  it "should not allow adding a client item, if item is present in another club catalog having same level but different schemes" do
    client = Fabricate(:client)
    scheme1 = Fabricate(:scheme, :name => "scheme1", :client => client)
    scheme2 = Fabricate(:scheme, :name => "scheme2", :client => client)

    client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
    scheme1_level_club = Fabricate(:level_club, :scheme => scheme1)
    scheme1_level_club.catalog.add([client_item1])

    scheme2_level_club = Fabricate(:level_club, :scheme => scheme2)
    scheme2_level_club.can_add?([client_item1]).should be_true
  end

  it "should return level clubs with specified level name" do
    scheme1 = Fabricate(:scheme, :name => "scheme1", :levels => ["level2"])
    level_club1 = Fabricate(:level_club, :level_name => 'level3', :scheme => scheme1)

    scheme1.level_clubs.with_level("level3").should == [level_club1]
  end

  it "should return level clubs with specified club name" do
    scheme1 = Fabricate(:scheme, :name => "scheme1", :clubs => ["gold"])
    level_club2 = Fabricate(:level_club, :club_name => 'silver', :scheme => scheme1)

    scheme1.level_clubs.with_club("silver").should == [level_club2]
  end

end