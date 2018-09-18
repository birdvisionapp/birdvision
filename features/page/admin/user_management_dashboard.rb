module Page
  module Admin
    module UserManagementDashboard

      def navigate_to_user_management_dashboard
        visit(admin_user_management_client_managers_path)
      end

      def create_client_manager row
        visit(admin_user_management_client_managers_path)
        click_on "New Client Manager"
        fill_in "Name", :with => row['name']
        select("#{row['client']}", :from => 'client_manager_client_id')
        fill_in "client_manager_email", :with => row['email']
        fill_in "client_manager_mobile_number", :with => row['mobile_number']
        click_on "Save"
      end

    end
  end
end

World(Page::Admin::UserManagementDashboard)
