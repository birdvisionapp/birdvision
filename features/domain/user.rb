module Domain
  module CukeUser
    def upload_users_for(csv_name, scheme, client)
      open_upload_participants_page
      upload_participants_from_csv csv_name, scheme, client
    end

    def login(username, password)
      navigate_to_login_page
      fill_and_submit_login_form(username, password)
      #assert verify_user_logged_in?, "User is not logged in"
    end

    def logout_user
      click_logout
    end
  end
end

World(Domain::CukeUser)