module Page
  module ActivateAccountPage

    def set_password_of_participant
      fill_in('user_password', :with => 'password')
      fill_in('user_password_confirmation', :with => 'password')
      click_button("Activate your account")
    end
  end
end

World(Page::ActivateAccountPage)