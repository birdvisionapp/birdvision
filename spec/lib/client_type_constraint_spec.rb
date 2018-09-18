require 'spec_helper'

describe ClientTypeConstraint do

  let(:user) { Fabricate(:user) }
  let(:request) { mock("request") }
  let(:warden) { mock("warden") }
  let(:single_redemption_scheme) { Fabricate(:single_redemption_scheme) }

  it "should return true if the user's client type matches specified type" do
    Fabricate(:user_scheme, :scheme => single_redemption_scheme, :user => user)
    warden.stub(:user).and_return(user)
    request.stub_chain(:env, :[]).and_return(warden)
    request.stub(:path_parameters).and_return(:scheme_slug => single_redemption_scheme.slug)

    ClientTypeConstraint.new(true).matches?(request).should be_true
  end

  it "should return true if no user logged-in" do
    Fabricate(:user_scheme, :scheme => single_redemption_scheme, :user => user)
    warden.stub(:user).and_return(nil)
    request.stub_chain(:env, :[]).and_return(warden)
    request.stub(:path_parameters).and_return(:scheme_slug => single_redemption_scheme.slug)

    ClientTypeConstraint.new(true).matches?(request).should be_true
  end
end