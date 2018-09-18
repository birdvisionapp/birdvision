require 'request_spec_helper'

feature "Client Manager" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "should list all the super admins" do
    Fabricate(:admin_user, :username => 'superman', :email => 'iamsuperman@mailinator.com')

    visit(admin_user_management_super_admins_path)
    within('.super-admins') do
      page.should have_content 'superman'
      page.should have_content 'iamsuperman@mailinator.com'
    end
  end

  context "creating new super admin" do
    scenario "should be successful for valid data" do
      visit(admin_user_management_super_admins_path)
      click_on "New Super Admin"
      page.should have_content 'New Super Admin'
      fill_in 'admin_user_username', :with => 'superman'
      fill_in 'admin_user_email', :with => 'admin_user_email@mailinator.com'
      click_on "Save"

      within('.super-admins') do
        page.should have_content 'superman'
        page.should have_content 'admin_user_email@mailinator.com'
      end
    end

    scenario "should redirect to super admin index, on cancel" do
      visit(admin_user_management_super_admins_path)
      click_on "New Super Admin"
      click_on 'Cancel'
      page.should have_content 'Super Admin Users'
      page.should have_link 'New Super Admin', new_admin_user_management_super_admin_path
    end
  end

end
