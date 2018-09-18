require 'spec_helper'

describe Csv::LevelClubBuilder do

  it "should assign level club automatically for 1x1 scheme" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
    attrs_without_level_club = {:garbage => 2}.stringify_keys

    updated_user_scheme = Csv::LevelClubBuilder.new(user_scheme, attrs_without_level_club).build

    updated_user_scheme.level.name.should == 'level1'
    updated_user_scheme.club.name.should == 'platinum'
  end

  it "should assign level club for mxn scheme" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3))
    attrs = {:level => 'level2', :club => 'gold'}.stringify_keys

    updated_user_scheme = Csv::LevelClubBuilder.new(user_scheme, attrs).build

    updated_user_scheme.level.name.should == 'level2'
    updated_user_scheme.club.name.should == 'gold'
  end

  it "should skip level club assignment if not given" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3))
    attrs_without_level_club = {}

    updated_user_scheme = Csv::LevelClubBuilder.new(user_scheme, attrs_without_level_club).build

    updated_user_scheme.level.name.should == 'level1'
    updated_user_scheme.club.name.should == 'platinum'
  end

  it "should assign nil level, nil club for mxn scheme given invalid level, club values" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3))
    attrs = {:level => 'garbage level', :club => 'garbage club'}.stringify_keys

    updated_user_scheme = Csv::LevelClubBuilder.new(user_scheme, attrs).build

    updated_user_scheme.level.name.should be_nil
    updated_user_scheme.club.name.should be_nil
  end

end