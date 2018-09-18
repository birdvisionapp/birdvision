require 'request_spec_helper'

feature "Clients Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "Should render new clients page" do
    visit(admin_clients_path)
    page.should have_content "There are no clients yet"
  end

  scenario "Should render clients page" do
    client = Fabricate(:client)
    visit(admin_clients_path)
    page.should have_content(client.client_name)
    page.should have_content(client.contact_name)
    page.should have_content(client.contact_email)
    page.should have_content(client.contact_phone_number)
    page.should have_content(client.points_to_rupee_ratio)
    page.should have_content(client.description)
    page.should have_content(client.notes)
  end

  scenario "Should render client detail page and back button should take user back to clients index page" do
    client = Fabricate(:client, :code => "xyz")
    visit(admin_clients_path)
    click_on "View"
    page.should have_content("Client Details")
    page.should have_content("Contact Details")
    page.should have_content("Additional Information")
    page.should have_content("xyz")
    click_on("Back")
    page.should have_content("Clients")
    page.should have_content("Add New Client")
    page.should have_content(client.client_name)
    page.should have_content(client.contact_name)
    page.should have_content(client.contact_email)
  end

  scenario "Should render client detail page with api details and back button should take user back to clients index page" do
    client = Fabricate(:client_allow_sso, :code => "xyz")
    visit(admin_clients_path)
    click_on "View"
    page.should have_content("Allow Single Sign On - ")
    page.should have_content("Allow OTP (One Time Password) - ")
    page.should have_content("xyz")
    click_on("Back")
    page.should have_content("Clients")
    page.should have_content("Add New Client")
    page.should have_content(client.client_name)
    page.should have_content(client.contact_name)
    page.should have_content(client.contact_email)
  end

  scenario "Should create new client" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The client test client was successfully created.")
    end
    within(".clients") do
      page.should have_content("test client")
    end
  end

  scenario "Should not create new client with client code of an existing client" do
    client = Fabricate(:client , :code => 'TC')
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The code is already in use. Please enter another code")
    end
  end

  scenario "Should not attach custom theme if subdomain is not specified" do
    client = Fabricate(:client)
    visit(edit_admin_client_path(client))

    attach_file "client_custom_theme", "#{Rails.root}/spec/fixtures/custom_theme.css"

    within(".site-customizations") do
      page.should_not have_content "Download existing theme"
      page.should have_content "Download template theme"
    end
    click_on "Save Client"
    within('.alert') do
      page.should have_content("Please specify a subdomain for which the custom theme should be applied")
    end
  end

  scenario "Should not create client if subdomain is duplicated" do
    client = Fabricate(:client, :domain_name => 'test.domain.com')
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_domain_name', :with => 'test.domain.com')
    attach_file "client_custom_theme", "#{Rails.root}/spec/fixtures/custom_theme.css"
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The subdomain already in use. Please enter another subdomain")
    end
  end

  scenario "Should not create new client without selecting otp sending option if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_otp')
    uncheck('client_allow_otp_email')
    uncheck('client_allow_otp_mobile')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("Please select atleast one OTP sending option")
    end
  end

  scenario "Should not create new client without otp expiration time if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_otp')
    check('client_allow_otp_email')
    check('client_allow_otp_mobile')
    fill_in('client_otp_code_expiration', :with => '')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("Please enter the OTP expiration time")
    end
  end

  scenario "Should not create new client with otp expiration time invalid format if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_otp')
    check('client_allow_otp_email')
    check('client_allow_otp_mobile')
    fill_in('client_otp_code_expiration', :with => 'te2345')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The OTP expiration time should be numeric")
    end
  end

  scenario "Should create new client with valid otp details if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_otp')
    check('client_allow_otp_email')
    check('client_allow_otp_mobile')
    fill_in('client_otp_code_expiration', :with => '7200')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The client test client was successfully created.")
    end
  end

  scenario "Should not update a client without selecting otp sending options if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    uncheck('client_allow_otp')
    uncheck('client_allow_otp_email')
    uncheck('client_allow_otp_mobile')
    click_on "Create Client"

    click_on "Edit"
    check('client_allow_otp')
    uncheck('client_allow_otp_email')
    uncheck('client_allow_otp_mobile')
    click_on "Save Client"

    within(".alert") do
      page.should have_content("Please select atleast one OTP sending option")
    end
  end

  scenario "Should not update a client without entering otp expiration time if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    check('client_allow_otp')
    check('client_allow_otp_email')
    check('client_allow_otp_mobile')
    fill_in('client_otp_code_expiration', :with => '100')
    click_on "Create Client"

    click_on "Edit"
    fill_in('client_otp_code_expiration', :with => '')
    click_on "Save Client"

    within(".alert") do
      page.should have_content("Please enter the OTP expiration time")
    end
  end

  scenario "Should update a client with valid otp details if allow otp checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    check('client_allow_otp')
    check('client_allow_otp_email')
    check('client_allow_otp_mobile')
    fill_in('client_otp_code_expiration', :with => '100')
    click_on "Create Client"

    click_on "Edit"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_otp_code_expiration', :with => '1234')
    click_on "Save Client"

    page.should have_content 'test client'
    within(".alert") do
      page.should have_content("The client test client was successfully updated.")
    end
  end

  scenario "Should be able to attach custom theme to clients if subdomain is specified" do
    client = Fabricate(:client)
    visit(edit_admin_client_path(client))

    fill_in('client_domain_name', :with => 'test.client.com')
    uncheck('client_allow_sso')
    attach_file "client_custom_theme", "#{Rails.root}/spec/fixtures/custom_theme.css"

    within(".site-customizations") do
      page.should_not have_content "Download existing theme"
      page.should have_content "Download template theme"
    end
    click_on "Save Client"
    within('.alert') do
      page.should have_content("The client #{client.client_name} was successfully updated.")
    end

    within("#client_#{client.id}") do
      click_on "Edit"
    end

    within(".site-customizations") do
      page.should have_link "Download existing theme"
      find_link("Download existing theme")[:target].should == "_blank"
      page.should have_link("Download template theme", href: "/theme_template.css")
      find_link("Download template theme")[:target].should == "_blank"
    end
  end

  scenario "Should cancel creation of new client" do
    visit(admin_clients_path)
    click_on "New Client"
    click_on "Cancel"
    within('#siteContent') do
      page.should have_content("Clients")
      page.should have_content("Add New Client")
    end
  end

  scenario "Should not create new client if client name already exists" do
    client = Fabricate(:client)
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => client.client_name)
    fill_in('client_points_to_rupee_ratio', :with => client.points_to_rupee_ratio)
    click_on "Create Client"
    within('.alert-error') do
      page.should have_content("The Client name is already in use. Please enter another title")
    end

  end

  scenario "Should update a client" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    click_on "Create Client"

    click_on "Edit"
    fill_in('client_client_name', :with => 'test client')
    click_on "Save Client"

    page.should have_content 'test client'
    within(".alert") do
      page.should have_content("The client test client was successfully updated.")
    end
  end

  scenario "Should cancel update of new client" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    click_on "Create Client"
    click_on "Edit"
    click_on "Cancel"
    within('#siteContent') do
      page.should have_content("Clients")
      page.should have_content("Add New Client")
    end
  end

  scenario "Should not create new client without client url if allow sso checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_sso')
    fill_in('client_client_url', :with => '')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("Please enter a client url")
    end
  end

  scenario "Should not create new client with invalid client url if allow sso checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_sso')
    fill_in('client_client_url', :with => 'testdomain')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("Client url format should be valid e.g domain.com")
    end
  end

  scenario "Should create new client with client url if allow sso checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_code', :with => 'TC')
    fill_in('client_points_to_rupee_ratio', :with => '10')
    check('client_allow_sso')
    fill_in('client_client_url', :with => 'http://test.client.com')
    click_on "Create Client"
    within('.alert') do
      page.should have_content("The client test client was successfully created.")
    end
  end

  scenario "Should not update a client with invalid client url if allow sso checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    check('client_allow_sso')
    fill_in('client_client_url', :with => 'http://test.client.com')
    click_on "Create Client"

    click_on "Edit"
    fill_in('client_client_url', :with => 'testdomain')
    click_on "Save Client"

    page.should_not have_content 'testdomain'
    within(".alert") do
      page.should have_content("Client url format should be valid e.g domain.com")
    end
  end

  scenario "Should update a client with valid client url if allow sso checked" do
    visit(admin_clients_path)
    click_on "New Client"
    fill_in('client_client_name', :with => "client")
    fill_in('client_code', :with => "CL")
    fill_in('client_points_to_rupee_ratio', :with => 5)
    check('client_allow_sso')
    fill_in('client_client_url', :with => 'http://test.client.com')
    click_on "Create Client"

    click_on "Edit"
    fill_in('client_client_name', :with => 'test client')
    fill_in('client_client_url', :with => 'http://update.client.com')
    click_on "Save Client"

    page.should have_content 'test client'
    within(".alert") do
      page.should have_content("The client test client was successfully updated.")
    end
  end

  context "reports" do
    scenario "Should download client report CSV for point based client" do
      acme = Fabricate(:client, :client_name => "Acme", :points_to_rupee_ratio => 2)
      big_bang_dhamaka = Fabricate(:scheme, :client => acme, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days)
      user1 = Fabricate(:user, :participant_id => "U1", :client => acme, :full_name => "First User", :activation_status => User::ActivationStatus::ACTIVATED, :activated_at => DateTime.new(2010, 12, 23))
      Fabricate(:user_scheme, :user => user1, :scheme => big_bang_dhamaka, :total_points => 500, :redeemed_points => 200)
      Fabricate(:order, :user => user1, :points => 200)

      visit admin_clients_path
      within("#client_#{acme.id}") do
        click_on 'Report'
      end

      headers = ["Client Name", "Scheme Name", "Participant ID",  "Final Achievement", "Rewards Redeemed"]
      data_values = ["Acme", "BBD", "U1", 200]

      headers.each { |header|
        page.should have_content(header)
      }

      data_values.each { |data|
        page.should have_content(data)
      }
    end
  end
end
