module Page
  module Admin
    module ClientDashboard

      def create_client_from row
        visit(admin_clients_path)
        click_on 'Add New Client'
        fill_in 'client_client_name', :with => row['client_name']
        fill_in 'client_contact_name', :with => row['client_contact_name']
        fill_in 'client_code', :with => row['code']
        fill_in 'client_contact_email', :with => row['email']
        fill_in 'client_contact_phone_number', :with => row['phone_number']
        fill_in 'client_points_to_rupee_ratio', :with => row['points_to_rupee_ratio']
        fill_in 'client_description', :with => row['description']
        click_on 'Create '
        end
      end
    end
  end
World(Page::Admin::ClientDashboard)