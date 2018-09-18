require 'spec_helper'

describe AccessGrant do
  
  it { should allow_mass_assignment_of :access_token }
  it { should allow_mass_assignment_of :access_token_expires_at }
  it { should allow_mass_assignment_of :client_id }
  it { should allow_mass_assignment_of :code }
  it { should allow_mass_assignment_of :refresh_token }
  it { should allow_mass_assignment_of :state }
  it { should allow_mass_assignment_of :user_id }

  it { should belong_to :user }
  it { should belong_to :client }

  it "should delete_all three days ago access_grants" do
    access_grant = Fabricate(:access_grant, :created_at => 3.days.ago)
    access_grant2 = Fabricate(:access_grant, :created_at => 4.days.ago)
    access_grant3 = Fabricate(:access_grant, :created_at => 2.days.ago)
    access_grant4 = Fabricate(:access_grant, :created_at => 5.days.ago)
    AccessGrant.prune!.should == 3
  end

  it "should authenticate access_grant for given code and client_id" do
    access_grant = Fabricate(:access_grant)
    AccessGrant.authenticate(access_grant.code, access_grant.client_id).should == access_grant
  end

  it "should generate code and access_token before create" do
    access_grant = Fabricate(:access_grant, :code => nil, :access_token => nil)
    access_grant.code.should_not be_nil
    access_grant.access_token.should_not be_nil
  end

  it "should start expiry period to the access resource" do
    access_grant = Fabricate(:access_grant, :access_token_expires_at => nil)
    access_grant.start_expiry_period!.should == true
    access_grant.access_token_expires_at.should_not be_nil
    access_grant.access_token.should_not be_nil
    access_grant.refresh_token.should_not be_nil
  end
  
end
