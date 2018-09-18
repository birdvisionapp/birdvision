require 'request_spec_helper'

feature "Admin - Schemes Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end
  let(:client) { Fabricate(:client, :client_name => 'Acme Inc') }

  context "list" do

    scenario "should display list of schemes" do
      scheme = Fabricate(:scheme, :name => 'Scheme 1', :client => client, :start_date => Date.new(2012, 8, 21),
                         :end_date => Date.new(2012, 8, 29),
                         :redemption_start_date => Date.new(2012, 8, 31), :redemption_end_date => Date.new(2012, 9, 21))
      past_scheme = Fabricate(:expired_scheme)
      future_scheme = Fabricate(:future_scheme)
      not_yet_started_scheme = Fabricate(:not_yet_started_scheme)
      active_scheme = Fabricate(:scheme)
      user_scheme = Fabricate(:user_scheme, :scheme => active_scheme, :total_points => 10_000)
      Fabricate(:order_item, :scheme => user_scheme.scheme, :order => Fabricate(:order, :user => user_scheme.user), :points_claimed => 5_000)
      visit(admin_schemes_path)

      within("#scheme_#{scheme.id}") do
        page.should have_content "Scheme 1"
        page.should have_content "Past"
        page.should have_content "August 21st, 2012 to August 29th, 2012"
        page.should have_content "August 31st, 2012 to September 21st, 2012"
        page.should have_content client.client_name
        page.should have_link("Edit", :href => edit_admin_scheme_path(scheme))
      end
      within("#scheme_#{past_scheme.id}") do
        page.should have_content past_scheme.name
        page.should have_content "Past"
      end
      within("#scheme_#{future_scheme.id}") do
        page.should have_content future_scheme.name
        page.should have_content "Upcoming"
      end
      within("#scheme_#{not_yet_started_scheme.id}") do
        page.should have_content not_yet_started_scheme.name
        page.should have_content "Upcoming"
      end
      within("#scheme_#{active_scheme.id}") do
        page.should have_content "10,000"
        page.should have_content "5,000"
        page.should have_content active_scheme.name
        page.should have_content "Ready For Redemption"
      end
    end

    scenario "should indicate that no schemes currently exist" do
      visit(admin_schemes_path)

      page.should have_content "There are no schemes yet"
    end
  end

  context "new" do
    scenario "should allow adding a new scheme" do
      existing_client = client

      visit(new_admin_scheme_path)

      select("#{client.client_name}", :from => 'scheme_client_id')

      fill_in('scheme_name', :with => 'Diwali Dhamaka')
      fill_in('scheme_start_date', :with => '23-10-2012')
      fill_in('scheme_end_date', :with => '23-11-2012')
      fill_in('scheme_redemption_start_date', :with => '25-11-2012')
      fill_in('scheme_redemption_end_date', :with => '23-12-2012')
      fill_in('level_club_config[level_name][]', :with => 'level1')
      fill_in('level_club_config[club_name][]', :with => 'club1')

      attach_file "scheme_poster", "#{Rails.root}/spec/fixtures/table.jpg"
      attach_file "scheme_hero_image", "#{Rails.root}/spec/fixtures/table.jpg"

      click_on("Create Scheme")

      within(".alert") do
        page.should have_content "The scheme Diwali Dhamaka was successfully created."
      end

      within(".schemes") do
        page.should have_content "Diwali Dhamaka"
        page.should have_content "Past"
      end
    end

    scenario "should provide date picker for date fields" do
      existing_client = client

      visit(new_admin_scheme_path)

      %w(start_date end_date redemption_start_date redemption_end_date).each { |date|
        page.should have_css("input#scheme_#{date}.datepicker")
      }

    end

  end

  context "edit" do
    scenario "should show the client as disabled" do
      scheme = Fabricate(:scheme, :client => client)

      visit(edit_admin_scheme_path(scheme))

      find("#scheme_client_id")["disabled"].should be_true
    end

    scenario "should render scheme index page after update" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client, :name => "Old Name")

      visit(edit_admin_scheme_path(scheme))

      fill_in('scheme_name', :with => 'New Name')
      fill_in('scheme_start_date', :with => '23-10-2012')
      fill_in('scheme_end_date', :with => '23-11-2013')
      fill_in('scheme_redemption_start_date', :with => '01-01-2013')
      fill_in('scheme_redemption_end_date', :with => '01-02-2013')

      click_on("Save Scheme")

      within(".alert") do
        page.should have_content "The scheme New Name was successfully updated."
      end

      within(".schemes") do
        page.should have_content "New Name"
      end
    end
  end

  context "report" do
    scenario "Should have download csv link" do
      flipkart = Fabricate(:supplier, :name => "flipkart")
      s2 = Fabricate(:item, :title => "samsung s2 black")

      Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s2), :quantity => 1,
                :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000, :supplier_id => flipkart.id)
      visit(admin_order_items_path)
      page.should have_link("Download")
    end

    scenario "Should download scheme report CSV for point based client" do
      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days)
      user1 = Fabricate(:user, :participant_id => "U1", :client => emerson, :full_name => "First User")
      Fabricate(:user_scheme, :user => user1, :scheme => big_bang_dhamaka, :total_points => 500, :redeemed_points => 200)

      visit admin_schemes_path
      within("#scheme_#{big_bang_dhamaka.id}") do
        click_on 'Report'
      end

      headers = ["Client Name", "Scheme Name"]
      data_values = ["Emerson", "BBD"]

      headers.each { |header|
        page.should have_content(header)
      }

      data_values.each { |data|
        page.should have_content(data)
      }
    end
  end
end