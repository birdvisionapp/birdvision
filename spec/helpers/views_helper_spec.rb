require 'spec_helper'

describe ViewsHelper do

  it "should return proper message when only 1 result is present" do
    results = double("results", :size => 1, :num_pages => 1)
    page_entries_info_message(results).should == "Displaying 1 result"
  end

  it "should return proper message when results are less than per page size" do
    results = double("results", :size => 3, :num_pages => 1)
    page_entries_info_message(results).should == "Displaying all 3 results"
  end

  it "should return proper message for results on page 1" do
    results = double("results", :num_pages => 2, :per_page => 11, :current_page => 1, :total_count => 20, :size => 11)
    page_entries_info_message(results).should == "Displaying 1 - 11 of 20 results"
  end

  it "should return proper message for results on intermediate page" do
    results = double("results", :num_pages => 2, :per_page => 11, :current_page => 2, :total_count => 20, :size => 9)
    page_entries_info_message(results).should == "Displaying 12 - 20 of 20 results"
  end

  it "should return correct class for correct state of order" do
    css_class_for_status("sent_to_supplier").should == "badge badge-warning"
    css_class_for_status("delivery_in_progress").should == "badge badge-inverse"
    css_class_for_status("delivered").should == "badge badge-success"
    css_class_for_status("incorrect").should == "badge badge-info"
    css_class_for_status("new").should == "badge badge-important"
  end

  it "should return correct class for the action to be performed" do
    class_of_status_action("incorrect").should == "btn"
    class_of_status_action("any other action").should == "btn btn-success"
  end

  it "should return all browsable schemes except for the current selected scheme" do
    client = Fabricate(:client)
    scheme = Fabricate(:scheme, :client => client, :name => "a")
    future_scheme = Fabricate(:future_scheme, :client => client, :name => "c")
    not_started_scheme = Fabricate(:not_yet_started_scheme, :client => client, :name => "d")

    user = Fabricate(:user, :client => client)
    user_scheme1 = Fabricate(:user_scheme, :user => user, :scheme => scheme)
    future_user_scheme = Fabricate(:user_scheme, :user => user, :scheme => future_scheme)
    Fabricate(:user_scheme, :user => user, :scheme => not_started_scheme)

    helper.stub(:current_user).and_return(user)
    helper.my_browsable_user_schemes_except(user_scheme1).should == [future_user_scheme]
  end


  context "date range" do
    it "should display date range given start, end date" do
      date_range(Date.new(2012, 2, 23), Date.new(2012, 5, 21)).should == "February 23rd, 2012 <b>to</b> May 21st, 2012"
    end
    it "should display date range given start date with no end date" do
      date_range(Date.new(2012, 2, 23), nil).should == "Effective from February 23rd, 2012"
    end
    it "should display date range given only end date" do
      date_range(nil, Date.new(2012, 2, 23)).should == "Upto February 23rd, 2012"
    end

    it "should return _ when both start and end date are nil" do
      date_range(nil, nil).should == '-'
    end

  end

  context "ldate" do
    it "should return localized date given a valid date" do
      ldate(Date.new(2012, 2, 23)).should == "23-02-2012"
    end

    it "should return nil if no date given" do
      ldate(nil).should be_nil
    end
  end

  context "active link" do
    it "returns active link" do
      helper.request.path = "dont_care"
      helper.stub(:controller_name).and_return("controller1")
      helper.active_link_to_if_one_of(%w(controller1 controller2), "dont_care", "url", {}).should include("active")
      helper.active_link_to_if_one_of(%w(controller1 controller2), "dont_care", "url", :class => "nav-header",
                                      :active_class => "nav-header nav-active active").should include("nav-header nav-active active")
    end
  end

  context "is_current_one_of?" do
    it "returns true when request controller is one of passed url parts" do
      helper.request.path = "dont_care"
      helper.stub(:controller_name).and_return("controller1")
      helper.is_current_one_of?(%w(controller1 controller2)).should == true
    end

    it "returns false when request controller is not any of the multiple passed url parts" do
      helper.request.path = "dont_care"
      helper.stub(:controller_name).and_return("controller1")

      helper.is_current_one_of?(%w(controller0 controller2)).should == false
    end

    it "returns false if given request path does not match the url parts" do
      helper.request.path = "controller1/action10"
      helper.is_current_one_of?(%w(action2 action1)).should == false
    end
  end

  context "catalog urls" do
    let(:client) { Fabricate(:client) }
    let!(:scheme) { Fabricate(:scheme, :levels => %w(level1 level2 level3), :clubs => %w(club1 club2), :client => client) }

    it "should include client, scheme and level club catalogs for client with single redemption scheme" do
      catalog_urls = catalog_urls(client)
      catalog_urls.should include(admin_level_club_catalog_path(scheme.level_clubs.first))
      catalog_urls.should include(edit_admin_level_club_catalog_path(scheme.level_clubs.first))
      catalog_urls.should include(admin_client_catalog_path(client))
      catalog_urls.should include(edit_admin_client_catalog_path(client))
      catalog_urls.should include(admin_scheme_catalog_path(scheme))
      catalog_urls.should include(edit_admin_scheme_catalog_path(scheme))
      catalog_urls.size.should == 16
    end

    it "should include scheme, level-club catalogs for client with single redemption scheme" do
      catalog_urls = scheme_urls(scheme)
      catalog_urls.should include(admin_level_club_catalog_path(scheme.level_clubs.first))
      catalog_urls.should include(edit_admin_level_club_catalog_path(scheme.level_clubs.first))
      catalog_urls.should include(admin_scheme_catalog_path(scheme))
      catalog_urls.should include(edit_admin_scheme_catalog_path(scheme))
      catalog_urls.size.should == 14
    end
  end

  it "should convert number to currency" do
    bvc_currency(123442.05).should == "1,23,442.05"
    bvc_currency(123442.0).should == "1,23,442"
    bvc_currency(123442.00).should == "1,23,442"
    bvc_currency(nil).should == "-"
    bvc_currency(1234.05).should == "1,234.05"
    bvc_currency(0).should == "0"
  end

  it "should display schemes for a client item" do
    client = Fabricate(:client)
    scheme1 = Fabricate(:scheme, :client => client, :name => "old scheme")
    scheme2 = Fabricate(:scheme, :client => client, :name => "new scheme")
    client_item = Fabricate(:client_item, :schemes => [scheme1, scheme2])
    output = schemes_for(client_item)
    output.should include("old scheme")
    output.should include("new scheme")
  end

  it "should display level clubs for a client item" do
    client = Fabricate(:client)
    scheme = Fabricate(:scheme, :levels => %w(level1), :clubs => %w(platinum gold), :client => client)
    scheme2 = Fabricate(:scheme, :name => "sbd", :client => client)
    client_item = Fabricate(:client_item, :level_clubs => scheme.level_clubs.take(2))
    client_item2 = Fabricate(:client_item, :level_clubs => scheme2.level_clubs.take(1))

    output = level_clubs_for(client_item, scheme)
    output.should == "Level1-Platinum, \nLevel1-Gold"

    output = level_clubs_for(client_item2, scheme2)
    output.should == "Level1-Platinum"
  end

  it "should return asset_host (used for prefetch)" do
    ActionController::Base.should_receive(:asset_host).and_return("cdn.bvc.com")

    asset_host.should == "cdn.bvc.com"
  end

  context "error page back url" do
    it "should return root_path for participants" do
      helper.stub_chain(:current_admin_user, :present?).and_return(false)
      helper.back_path.should == root_path
    end

    it "should return participants path for super admin user" do
      current_admin_user = mock("admin_user")
      current_admin_user.stub(:role).and_return(AdminUser::Roles::SUPER_ADMIN)

      helper.stub(:current_admin_user).and_return(current_admin_user)

      helper.back_path.should == admin_users_path
    end

    it "should return clients path depending client_manager admin user" do
      current_admin_user = mock("admin_user")
      current_admin_user.stub(:role).and_return(AdminUser::Roles::CLIENT_MANAGER)

      helper.stub(:current_admin_user).and_return(current_admin_user)

      helper.back_path.should == admin_clients_path
    end

    it "should return dashboard path depending reseller admin user" do
      current_admin_user = mock("admin_user")
      current_admin_user.stub(:role).and_return(AdminUser::Roles::RESELLER)

      helper.stub(:current_admin_user).and_return(current_admin_user)

      helper.back_path.should == admin_sales_reseller_dashboard_index_path
    end

  end
end

