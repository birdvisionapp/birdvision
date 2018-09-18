require 'request_spec_helper'

feature "Admin - Users Page" do
  before :each do
    @scheme = Fabricate(:scheme_3x3, :name => 'MyScheme', :total_budget_in_rupees => 5_000, :client => Fabricate(:client, :client_name => 'Acme'))
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "should list all participants" do
    scheme1 = Fabricate(:scheme, :name => 'TestScheme')
    scheme2 = Fabricate(:scheme, :name => 'MySecondScheme', :client => scheme1.client)
    client = Fabricate(:client, :code => 'cc1')
    user = Fabricate(:user, :client => client)
    Fabricate(:user_scheme, :user => user, :scheme => scheme1)
    Fabricate(:user_scheme, :user => user, :scheme => scheme2, :total_points => 20_00_000)

    visit admin_users_path

    within(".users") do
      page.should have_content user.participant_id
      page.should have_content user.username
      page.should have_content user.full_name
      page.should have_content "TestScheme (10,00,000)"
      page.should have_content "MySecondScheme (20,00,000)"
    end

    within(".actions") do
      page.should have_link('Download', {:href => admin_users_path(:format => "csv")})
    end
    select("Activated", :from => "q_activation_status_eq")
    click_on "Filter"

    click_on 'Download'
    page.body.lines.count.should == 2
  end

  scenario "should have link to download template" do
    visit (import_csv_admin_users_path)
    select("Acme - MyScheme", :from => 'scheme')
    within(".alert-info") do
      page.should have_link "template", :href => admin_scheme_csv_template_path(@scheme, :csv)
    end
  end

  scenario "should fail bulk creation if issues in validation are found" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users_with_issues.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")

    page.find(".accordion-toggle").click

    within(".accordion-inner") do
      page.should have_content("Row Number 2 has the following errors")
      page.should have_content("Row Number 3 has the following errors")
    end
  end

  scenario "should fail bulk creation if records with same participant ids are found" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users_with_duplicate_records.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")

    page.find(".accordion-toggle").click

    within(".accordion-inner") do
      page.should have_content("Uploaded file contains duplicate rows for id(s) [\"AB12\"]")
    end
  end

  scenario "should be able to update user attributes for a scheme" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")

    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/update_users.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")

    visit admin_users_path
    page.should have_content("9,01,09,410")
    page.should have_content("1,01,20,320")
  end

  scenario "should be able to upload user with attributes containing unicode characters" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/user_with_unicode_characters.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")
    within(".accordion-group") do
      page.should have_content("user_with_unicode_characters.csv")
      page.should have_content("Success")
    end

    visit admin_users_path
    page.should have_content("bob")
    page.should have_content("1111111119")
  end

  #it "should fail bulk creation if records with same participant ids are found" do
  #  post :upload_csv, "csv" => Rack::Test::UploadedFile.new("spec/fixtures/upload_users_with_duplicate_records.csv", "text/csv"), "scheme" => @scheme
  #  User.count.should == 0
  #  flash[:alert].should == "Uploaded file contains duplicate rows for participant id(s) [\"AB12\"]"
  #  response.should redirect_to import_csv_admin_users_path
  #end

  scenario "should not update user attributes for a scheme if attribute value is not provided in csv" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")

    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/update_users_empty_attrs.csv"
    select("Acme - MyScheme", :from => 'scheme')

    click_on("Start Upload")
    visit admin_users_path
    page.should have_content("400")
    page.should have_content("200")
  end

  scenario "should update user attributes for same client but different schemes" do
    @scheme2 = Fabricate(:scheme_3x3, :name => 'MySecondScheme', :client => @scheme.client, :redemption_start_date => Date.today + 50.days, :redemption_end_date => Date.today + 59.days)

    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users.csv"
    select("Acme - MyScheme", :from => 'scheme')
    click_on("Start Upload")
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/update_users.csv"
    select("Acme - MySecondScheme", :from => 'scheme')
    click_on("Start Upload")
    visit admin_users_path
    page.should have_content("#{@scheme.name} (200) #{@scheme2.name} (1,01,20,120)")
  end

  scenario "should not update user attributes if there is a failure in upload due to wrong data" do
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users.csv"
    select("Acme - MyScheme", :from => 'scheme')
    click_on("Start Upload")
    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/update_malformed_users_data.csv"
    select("Acme - MyScheme", :from => 'scheme')
    click_on("Start Upload")

    page.first(".accordion-toggle").click

    within(".accordion-inner") do
      page.should have_content("Row Number 2 has the following errors")
      page.should have_content("Please enter the participant id")
    end

    visit(admin_users_path)
    page.should_not have_content("9,01,09,010")
    page.should_not have_content("1,01,20,120")
  end

  scenario "should be able to upload users with achievements" do
    Fabricate(:scheme_3x3, :single_redemption => true, :client => Fabricate(:client, :client_name => "Single Redemption Client"), :name => 'Single Redemption Scheme', :total_budget_in_rupees => 5_000)

    visit(import_csv_admin_users_path)
    attach_file "csv", "#{Rails.root}/spec/fixtures/upload_users_with_achievements.csv"
    select("Single Redemption Client - Single Redemption Scheme", :from => 'scheme')

    click_on("Start Upload")
    visit admin_users_path


    find("h1").should have_content("Participants")
    first(:tr, ".user").should have_content("Single Redemption Scheme")

    within(".users") do
      ["kunalbvc@mailinator.com", "9881111111", "300", "Single Redemption Scheme", "Geet", "geetbvc@mailinator.com", "1234567890", "Single Redemption Client"].each { |data|
        page.should have_content(data)
      }
    end

    first(:link, "View").click

    within("#siteContent") do
      page.should have_content("Current Achievements")
      page.should have_content("Platinum Start Target")
      page.should have_content("Gold Start Target")
      page.should have_content("Silver Start Target")
      page.should have_content("Club")
      page.should have_content("Level")
      page.should have_content("Region")
      page.should have_content("Total Points")

      page.should have_content("level2")
      page.should have_content("platinum")
    end
  end


  context "view a single participant" do
    scenario "should display participant details" do
      scheme1 = Fabricate(:scheme, :start_date => Date.tomorrow, :end_date => Date.tomorrow + 60.days, :redemption_start_date => Date.tomorrow + 30.days, :redemption_end_date => Date.tomorrow + 50.days)
      scheme2 = Fabricate(:scheme, :start_date => Date.today - 20.days, :end_date => Date.tomorrow + 60.days, :redemption_start_date => Date.tomorrow + 30.days, :redemption_end_date => Date.tomorrow + 50.days)

      user = Fabricate(:user)
      Fabricate(:user_scheme, :user => user, :scheme => scheme1)
      Fabricate(:user_scheme, :user => user, :scheme => scheme2)

      visit admin_users_path
      within('.users_stats') do
        page.should have_content("Activated:1")
        page.should have_content("Total Users:1")
      end
      within("#user_#{user.id}") do
        click_on 'View'
      end
      within("#siteContent") do
        page.should have_content(user.username)
        page.should have_content(user.full_name)
        page.should have_content(user.created_at.to_date.to_formatted_s(:long_ordinal))
        page.should have_content(user.mobile_number)
        page.should have_content(user.address)
        page.should have_content(user.client_name)
        page.should have_content("Total Points 1000000")
      end
    end

    scenario "should show activation link to admin for users to whom link is sent but have not activated yet, or have requested password reset" do
      user = Fabricate(:user)
      User.generate_activation_token_for user.id

      visit admin_users_path
      within("#user_#{user.id}") do
        click_on 'View'
      end
      within("#siteContent") do
        page.should have_content("Activation Link")
        page.should have_content(edit_user_password_path(user.reset_password_token))
      end
    end

    scenario "should not show activation link to admin for other users" do
      user = Fabricate(:user)

      visit admin_users_path
      within("#user_#{user.id}") do
        click_on 'View'
      end
      within("#siteContent") do
        page.should_not have_content("Activation Link")
        page.should_not have_content(edit_user_password_path(user.reset_password_token))
      end
    end

  end
end


