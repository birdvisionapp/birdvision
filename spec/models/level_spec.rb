require 'spec_helper'

describe Level do
  it { should allow_mass_assignment_of(:name) }
  it { should validate_presence_of(:name) }

  it { should have_one(:level_club) }

  it "should return level for given scheme and level name" do
    scheme = Fabricate(:scheme)
    Level.with_scheme_and_level_name(scheme, "level1").should == [Level.find_by_name("level1")]
  end
end