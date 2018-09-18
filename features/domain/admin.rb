module Domain
  module CukeAdmin

    def open_admin_dashboard
      navigate_to_admin_home
    end

    def login_admin_user(username, password)
      navigate_to_admin_login_page
      fill_and_submit_admin_login_form(username, password)
      assert verify_admin_user_logged_in?(username), "Admin User is not logged in"
    end

    def verify_order_present_in_admin_dashboard(item, user)
      navigate_to_order_dashboard
      verify_order_present_for_item(item, user)
    end

    def change_order_status_to item, status
      navigate_to_order_dashboard
      change_status_to item, status
    end

    def create_new_reseller reseller_info
      navigate_to_resellers_page
      create_reseller reseller_info
      end

    def create_new_client_manager client_manager_info
      navigate_to_user_management_dashboard
      create_client_manager client_manager_info
    end

    def assign_reseller_to_client reseller, client, finders_fee, details
      navigate_to_resellers_page
      add_client_to_reseller reseller, client, finders_fee, details
    end

  end
end

World(Domain::CukeAdmin)