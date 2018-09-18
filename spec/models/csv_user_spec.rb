require 'spec_helper'

describe CsvUser do
  let(:scheme) { Fabricate(:scheme, :levels => %w(level1), :clubs => %w(platinum gold)) }
  let(:csv_user) { CsvUser.new(scheme, false) }

  def row(overrides)
    {:participant_id => '123', :full_name => 'Bob', :email => 'bob@mailinator.com', :mobile_number => '9876543210', :landline_number => '9876543210',
     :address => 'Galaxy apts', :pincode => '654321', :points => '200', :notes => '', :current_achievements => '2000', :gold_start_target => '1000',
     :platinum_start_target => '5000', :club => 'gold', :level => 'level1', :region => 'west'}.merge(overrides).stringify_keys
  end

  it "should update targets for existing user" do
    existing_user = Fabricate(:user, :participant_id => '12345')
    Fabricate(:user_scheme_with_targets, :user => existing_user, :scheme => scheme, :targets => {:gold => 30000})

    user = csv_user.from_hash(row(:participant_id => '12345', :gold_start_target => '90000'), {'12345' => existing_user})
    user.user_schemes.first.targets.find { |target| target.club.name == 'gold' }.start.should == 90000
  end

  it "allow csv assignment" do
    csv_user.headers.should =~
        %w(participant_id full_name email mobile_number landline_number address pincode points notes
        current_achievements gold_start_target platinum_start_target
        club region level)
  end

  it "should return unique attribute" do
    csv_user.unique_attribute.should == "participant_id"
  end

  it "should set platinum target as zero if none specified" do
    user = csv_user.from_hash(row(:platinum_start_target => nil), {})
    user.valid?

    user.errors.full_messages.should == []
  end

  it "should consider record as invalid if target specified is alphanumeric" do
    user = csv_user.from_hash(row(:platinum_start_target => 'a'), {})
    user.valid?

    user.errors.full_messages.should == ["Start is not a number"]
  end

  it "should consider record as invalid if a different level is specified other than permitted" do
    user = csv_user.from_hash(row(:level => 'garib_level'), {})
    user.valid?

    user.errors.full_messages.should == ["Level should be one of the following: level1"]
  end

  it "should consider record as invalid if a different club is specified other than permitted" do
    user = csv_user.from_hash(row(:club => 'garib_club'), {})
    user.valid?

    user.errors.full_messages.should == ["Club should be one of the following: platinum, gold"]
  end

  it "should allow uploading user if club are not specified" do
    user = csv_user.from_hash(row(:club => nil), {})
    user.valid?

    user.errors.full_messages.should == []
  end

  it "should return csv template" do
    csv_user.template.should == "participant_id,full_name,email,mobile_number,landline_number,address,pincode,points,notes,region,current_achievements,platinum_start_target,gold_start_target,level,club"
  end

  it "should ignore participant_id case for user upload" do
    existing_user = Fabricate(:user, :participant_id => 'participant', :full_name => 'ace')

    user = csv_user.from_hash(row(:full_name => 'bob', :participant_id => "PARTICIPANT"), {"participant" => existing_user})

    user.full_name.should == 'bob'
  end

  context "skip update for blank values" do
    let(:existing_user) { Fabricate(:user, :participant_id => 'participant', :full_name => 'ace') }

    it "should skip update of level, club if not specified in the update csv" do

      user_scheme = Fabricate(:user_scheme, :user => existing_user, :scheme => Fabricate(:scheme_3x3))
      assign_level_club(user_scheme, "level1", "platinum")

      user = csv_user.from_hash(row(:participant_id => "participant", :level => "", :club => ""), {"participant" => existing_user})

      user.user_schemes.first.level.name.should == "level1"
      user.user_schemes.first.club.name.should == "platinum"
    end

    it "should update level, club regardless if given 1xm" do
      user_scheme = Fabricate(:user_scheme, :user => existing_user, :scheme => scheme)
      assign_level_club(user_scheme, "level1", "platinum")

      user = csv_user.from_hash(row(:participant_id => "participant", :level => "", :club => ""), {"participant" => existing_user})

      user.user_schemes.first.level.name.should == "level1"
      user.user_schemes.first.club.name.should == "platinum"

    end

    it "should skip updating a target if value is not given in upload csv" do
      existing_user = Fabricate(:user, :participant_id => '12345')
      Fabricate(:user_scheme_with_targets, :user => existing_user, :scheme => scheme, :targets => {:gold => 30000})

      user = csv_user.from_hash(row(:participant_id => '12345', :gold_start_target => ''), {existing_user.participant_id => existing_user})
      user.user_schemes.first.targets.find { |target| target.club.name == 'gold' }.start.should == 30000
    end

    it "should skip updating current_achievements if value is not given in the csv" do
      existing_user = Fabricate(:user, :participant_id => '12345')
      Fabricate(:user_scheme, :user => existing_user, :scheme => scheme, :current_achievements => 10_000)
      user = csv_user.from_hash(row(:participant_id => '12345', :current_achievements => ''), {existing_user.participant_id => existing_user})

      user.user_schemes.first.current_achievements.should == 10_000
    end
  end
end