require 'spec_helper'

describe LevelClubCatalogs do
  let(:user_scheme_3x3) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3)) }
  let(:scheme_1x1) { Fabricate(:scheme, :levels => %w(level1), :clubs => %w(club1)) }
  let(:user_scheme_1x1) { Fabricate(:user_scheme, :scheme => scheme_1x1) }

  it "should return club catalogs for user's level" do
    update_level_club(user_scheme_3x3, "level2", nil)
    level_club_catalogs = LevelClubCatalogs.new(user_scheme_3x3)

    level_club_catalogs.club_catalogs.size.should == 3
    level_club_catalogs.club_catalogs.collect { |catalog| catalog.level_club.level.name }.uniq.should == %w(level2)
  end

  it "should return club catalog by id" do
    update_level_club(user_scheme_3x3, "level2", nil)
    level_club_catalogs = LevelClubCatalogs.new(user_scheme_3x3)
    level2_platinum = level_club_for(user_scheme_3x3.scheme, "level2", "platinum")

    club_catalog = level_club_catalogs.club_catalog(level2_platinum.id)
    club_catalog.level_club.should == level2_platinum
    club_catalog.user_scheme.should == user_scheme_3x3

  end

  it "should return nil for club catalog if no catalog with given id exists" do
    update_level_club(user_scheme_3x3, "level2", nil)
    level_club_catalogs = LevelClubCatalogs.new(user_scheme_3x3)

    club_catalog = level_club_catalogs.club_catalog(28762131233)
    club_catalog.should be_nil
  end

  it "should identify if the user has only one applicable club catalog" do
    update_level_club(user_scheme_1x1, "level1", nil)
    level_club_catalogs = LevelClubCatalogs.new(user_scheme_1x1)

    level_club_catalogs.size.should == 1
    level_club_catalogs.single_catalog?.should be_true

  end

  it "should return featured items" do
    client_item = Fabricate.build(:client_item)
    ClientItem.should_receive(:featured_items).with(user_scheme_1x1.applicable_level_clubs).and_return([client_item])

    featured_items = LevelClubCatalogs.new(user_scheme_1x1).featured
    featured_items.size.should == 1
    featured_items.first.should == client_item
  end

  it "should return applicable point range" do
    LevelClubCatalogs.any_instance.should_receive(:point_range_for).with(user_scheme_1x1)

    LevelClubCatalogs.new(user_scheme_1x1).point_range
  end

  it "should return applicable sub categories" do
    LevelClubCatalogs.any_instance.should_receive(:get_categories_for).with(user_scheme_1x1.applicable_level_clubs)

    LevelClubCatalogs.new(user_scheme_1x1).sub_categories
  end

  it "should return applicable parent categories" do
    LevelClubCatalogs.any_instance.should_receive(:get_parent_categories_for).with(user_scheme_1x1.applicable_level_clubs)

    LevelClubCatalogs.new(user_scheme_1x1).categories
  end
end