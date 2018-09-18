require 'spec_helper'

describe Csv::TargetBuilder do

  it "should create targets for given attributes " do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
    attrs = {:platinum_start_target => '5000'}.stringify_keys

    targets = Csv::TargetBuilder.new(user_scheme, %w(platinum_start_target), attrs).build

    targets.first.start.should == 5000
    targets.first.club.name.should == "platinum"
  end

  it "should update existing targets for given attributes " do
    user_scheme = Fabricate(:user_scheme_with_targets, :scheme => Fabricate(:scheme), :targets => {:platinum => 300})
    attrs = {:platinum_start_target => '5000', :garbage => 'ignore'}.stringify_keys

    club_target_names = %w(platinum_start_target gold_start_target silver_start_target)
    targets = Csv::TargetBuilder.new(user_scheme, club_target_names, attrs).build

    targets.first.start.should == 5000
  end
end