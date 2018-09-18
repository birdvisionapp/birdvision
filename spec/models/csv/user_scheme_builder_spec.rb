require 'spec_helper'

describe Csv::UserSchemeBuilder do
  let(:scheme) { Fabricate.build(:scheme) }
  let(:user) { Fabricate.build(:user) }

  context "replace points" do
    it "should create user scheme for given attributes" do
      attrs = {:points => '200', :current_achievements => '2000', :region => 'west'}.stringify_keys

      user_scheme = Csv::UserSchemeBuilder.new(scheme, user, false, attrs).build

      user.user_schemes.should == [user_scheme]
      user_scheme.current_achievements.should == 2000
      user_scheme.total_points.should == 200
      user_scheme.region.should == 'west'
    end

    it "should existing user scheme for given attributes" do
      user.user_schemes << Fabricate.build(:user_scheme, :user => user, :scheme => scheme, :current_achievements => 1000)
      attrs = {:current_achievements => '2000', :garbage => 'gfsdj'}.stringify_keys

      user_scheme = Csv::UserSchemeBuilder.new(scheme, user, false, attrs).build

      user.user_schemes.should == [user_scheme]
      user_scheme.current_achievements.should == 2000
    end
  end

  context "add points" do
    it "should create user scheme for given attributes" do
      attrs = {:points => '200'}.stringify_keys
      user_scheme = Csv::UserSchemeBuilder.new(scheme, user, true, attrs).build

      user.user_schemes.should == [user_scheme]
      user_scheme.total_points.should == 200
    end

    it "should update existing user scheme for given attributes" do
      user.user_schemes << Fabricate.build(:user_scheme, :user => user, :scheme => scheme, :total_points => 200)
      attrs = {:points => 100}.stringify_keys

      user_scheme = Csv::UserSchemeBuilder.new(scheme, user, true, attrs).build

      user.user_schemes.should == [user_scheme]
      user_scheme.total_points.should == 300
    end
  end
end
