module Page
  module ActivateAdminAccountPage

    def set_password_of_admin
      fill_in('admin_user_password', :with => 'password')
      fill_in('admin_user_password_confirmation', :with => 'password')
      click_button("Activate your account")
    end
  end
end

World(Page::ActivateAdminAccountPage)
