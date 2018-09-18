require 'request_spec_helper'

feature "Client Manager" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "should list all the client managers" do
    client_manager = Fabricate(:client_manager, :name => 'Some name', :mobile_number => '1234567890')

    visit(admin_user_management_client_managers_path)

    within('.client-managers') do
      page.should have_content client_manager.name
      page.should have_content client_manager.client.client_name
      page.should have_content client_manager.mobile_number
      page.should have_link "View", admin_user_management_client_manager_path(client_manager)
      page.should have_link "Edit", edit_admin_user_management_client_manager_path(client_manager)
    end
  end

  scenario "should show details of client manager" do
    client = Fabricate(:client, :client_name => 'Acme Inc.')
    client_manager = Fabricate(:client_manager, :name => 'Batman', :email => 'batman@darkcave.com', :mobile_number => '1234567890', :client => client)
    visit(admin_user_management_client_managers_path)
    within("#client_manager_#{client_manager.id}") do
      click_on "View"
    end
    page.should have_content 'Batman'
    page.should have_content 'Acme Inc.'
    page.should have_content 'batman@darkcave.com'
    page.should have_content '1234567890'
  end

  context "creating new client manager" do
    scenario "should be successful for valid data" do
      client = Fabricate(:client)

      visit(admin_user_management_client_managers_path)
      click_on "New Client Manager"
      page.should have_content 'New Client Manager'
      fill_in "Name", :with => 'client manager name'
      select("#{client.client_name}", :from => 'client_manager_client_id')
      fill_in "client_manager_email", :with => 'client_manager_email@client.com'
      fill_in "client_manager_mobile_number", :with => '1234567890'
      click_on "Save"

      within('.client-managers') do
        page.should have_content 'client manager name'
      end
    end

    scenario "should redirect to client manager index, on cancel" do
      client_manager = Fabricate(:client_manager)
      visit(admin_user_management_client_managers_path)
      click_on "New Client Manager"
      click_on 'Cancel'
      within('.client-managers') do
        page.should have_content client_manager.name
      end
    end
  end

  context "update client manager" do
    scenario "should allow editing details other than its client associated" do
      client_manager = Fabricate(:client_manager)
      visit admin_user_management_client_managers_path
      within("#client_manager_#{client_manager.id}") do
        click_on 'Edit'
      end
      page.should have_content 'Edit Client Manager Details'
      find('#client_manager_client_id')['disabled'].should be_true
      fill_in('client_manager_name', :with => 'New Name')
      click_on 'Save'
      within('.alert-success') do
        page.should have_content 'Client manager was successfully updated.'
      end
      page.should have_content 'New Name'
    end

    scenario "should redirect to client manager index, on cancel of edit" do
      client_manager = Fabricate(:client_manager)
      visit edit_admin_user_management_client_manager_path(client_manager)
      find('#client_manager_client_id')['disabled'].should be_true
      fill_in('client_manager_name', :with => 'New Name')
      click_on 'Cancel'
      within('.client-managers') do
        page.should have_content client_manager.name
      end
    end
  end
end
