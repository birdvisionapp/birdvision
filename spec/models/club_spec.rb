require 'spec_helper'

describe Club do
  it { should allow_mass_assignment_of(:name) }
  it { should validate_presence_of(:name) }

  it { should allow_mass_assignment_of(:rank) }
  it { should validate_numericality_of(:rank).only_integer.with_message(/.*/) }
  it { should validate_presence_of(:rank) }

  it { should have_one(:level_club) }

  it "should return club for given scheme and club name" do
    scheme = Fabricate(:scheme)
    Club.with_scheme_and_club_name(scheme, "platinum").should == [Club.find_by_name("platinum")]
  end

  it "should identify if given club is better than specified club" do
    scheme = Fabricate(:scheme, :levels => %w(level1), :clubs => %w(platinum gold silver))
    platinum_club = scheme.clubs.where(:name => 'platinum').first
    gold_club = scheme.clubs.where(:name => 'gold').first
    silver_club = scheme.clubs.where(:name => 'silver').first

    gold_club.better_than?(silver_club).should be_true
    gold_club.better_than?(gold_club).should be_false
    gold_club.better_than?(platinum_club).should be_false
    gold_club.better_than?(nil).should be_true
  end

  it "should identify if club is better by rank" do
    club1 = Fabricate.build(:club, :rank => 1)
    club2 = Fabricate.build(:club, :rank => 2)
    club1.better_than?(club2).should be_true
  end
end
