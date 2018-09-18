require 'spec_helper'

describe UserCatalogHelper do
  context "point based" do
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => scheme) }
    let(:scheme) { Fabricate(:scheme_3x3) }
    let(:user) { user_scheme.user }

    it "should return client items catalog_path" do
      helper.stub(:current_user).and_return(user)

      helper.catalog_path_for(user_scheme).should == catalogs_path(:scheme_slug => scheme.slug)
    end

    it "should return level-club catalog path if user_scheme has only one applicable level-club" do
      scheme = Fabricate(:scheme, :levels => %w(level1 level2), :clubs => %w(club1))
      user_scheme1 = Fabricate(:user_scheme, :scheme => scheme,
        :level => Level.with_scheme_and_level_name(scheme, 'level1').first, :club => Club.with_scheme_and_club_name(scheme, 'club1').first)
      helper.stub(:current_user).and_return(user_scheme1.user)

      helper.catalog_path_for(user_scheme1).should == catalog_path(:scheme_slug => scheme.slug, :id => user_scheme1.applicable_level_clubs.first.id)
    end

    it "should return search path" do
      helper.stub(:current_user).and_return(user)
      helper.search_path_for(user_scheme).should == search_catalog_path(:scheme_slug => scheme.slug)
    end

    it "should return item path" do
      helper.stub(:current_user).and_return(user)
      client_item = Fabricate(:client_item, :client_catalog => user.client.client_catalog)
      helper.client_item_path_for(client_item, user_scheme).should == client_item_path(:slug => client_item, :scheme_slug => scheme.slug)
    end
  end
  context "single redemption" do
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3, :single_redemption => true)) }
    let(:scheme) { user_scheme.scheme }
    let(:user) { user_scheme.user }

    it "should return single redemption catalog_path" do
      helper.stub(:current_user).and_return(user)
      helper.catalog_path_for(user_scheme).should == catalogs_path(:scheme_slug => scheme.slug)
    end

    it "should return item path" do
      helper.stub(:current_user).and_return(user)
      client_item = Fabricate(:client_item, :client_catalog => user.client.client_catalog)
      helper.client_item_path_for(client_item, user_scheme).should == client_item_path(:scheme_slug => scheme.slug, :slug => client_item)
    end
  end

  it "should return user items corresponding to given items, user_scheme" do
    client_item = Fabricate.build(:client_item)
    user_scheme = Fabricate.build(:user_scheme, :scheme => Fabricate(:scheme))

    user_items = user_items(user_scheme, [client_item])
    user_items.size.should == 1
    user_items.first.user_scheme.should == user_scheme
    user_items.first.client_item.should == client_item
  end

  it "should return nil unless allow otp for client" do
    client = Fabricate(:client, :domain_name => "abc.bvc.com", :allow_otp => false)
    helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
    helper.otp_sending_option.should == nil
  end

  it "should return otp sending option if allow otp for client" do
    client = Fabricate(:client, :domain_name => "abc.bvc.com", :allow_otp => true, :allow_otp_email => true, :allow_otp_mobile => true, :otp_code_expiration => 3200)
    helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
    helper.otp_sending_option.should == 'Email/Mobile number'
  end

  it "should return current user client name" do
    client = Fabricate(:client, :client_name => 'test name', :domain_name => "abc.bvc.com")
    helper.stub(:current_user).and_return(Fabricate(:user, :client => client))
    helper.current_user_client_name.should == 'test name'
  end

end
