require 'spec_helper'

describe Target do
  it { should belong_to :user_scheme }
  it { should belong_to :club }

  it { should validate_presence_of :user_scheme }
  it { should validate_presence_of :club }

  it { should allow_mass_assignment_of :user_scheme }
  it { should allow_mass_assignment_of :club }

  it { should validate_numericality_of(:start) }
  it { should_not allow_value(-1).for(:start) }

  it { should be_trailed }

  it "should allow nil values for target start" do
    target = Fabricate.build(:target, :start => nil, :club => Fabricate(:club), :user_scheme => Fabricate(:user_scheme, :scheme => Fabricate(:scheme)))
    target.valid?.should == true
  end
end