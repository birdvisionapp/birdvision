require 'spec_helper'

describe StylesheetHelper do

  context "custom theme" do
    it "should return client's custom theme url if host matches client's domain_name" do
      client = Fabricate(:client, :domain_name => "abc.bvc.com",
                         :custom_theme => File.new("#{Rails.root}/spec/fixtures/custom_theme.css"))
      helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
      helper.custom_theme_present?.should == true
      helper.custom_theme_url.should == client.custom_theme.url
    end

    it "should return false if custom theme for a client is not present" do
      client = Fabricate(:client, :domain_name => "abc.bvc.com")
      helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
      helper.custom_theme_present?.should == false
    end

    it "should return false if no client is found for the requests domain name" do
      client = Fabricate(:client, :domain_name => "xyz.bvc.com")
      helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
      helper.custom_theme_present?.should == false
    end
  end

end

