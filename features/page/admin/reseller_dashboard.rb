module Page
  module Admin
    module ResellerDashboard

      def navigate_to_resellers_page
        visit(admin_user_management_resellers_path)
      end

      def create_reseller row
        click_on "Add New Reseller"
        fill_in "reseller_name", :with => row["name"]
        fill_in "reseller_email", :with => row["email"]
        fill_in "reseller_phone_number", :with => row["phone_number"]
        click_button("Create Reseller")
      end

      def add_client_to_reseller reseller, client, finders_fee, details
        table_row_id = find(:xpath, "//td[text()='#{reseller}']/..")[:id]
        within("##{table_row_id}") do
          click_on "Associate a client"
        end
        assign_client(client, finders_fee, details)
      end

      def assign_client client, finders_fee, details
        select client, :from => "client_reseller_client_id"
        fill_in "client_reseller_finders_fee", :with => finders_fee
        fill_in "client_reseller_payout_start_date", :with => Date.today.strftime("%d-%b-%Y")
        details.hashes.each_with_index do |row, index|
          fill_in "client_reseller_slabs_attributes_#{index}_lower_limit", :with => row["slab"]
          fill_in "client_reseller_slabs_attributes_#{index}_payout_percentage", :with => row["percentage"]
        end
        click_on "Associate client"
      end
    end
  end
end

World(Page::Admin::ResellerDashboard)
