module Page
  module Admin
    module SupplierDashboard

      def navigate_to_supplier_dashboard
        visit(new_admin_supplier_path)
      end

      def create_supplier row
        row.each do |field_arr|
          fill_in("supplier_#{field_arr.first.gsub(' ', '_').downcase}", :with => field_arr.last)
        end
        click_button("Save Supplier")
      end

    end
  end
end

World(Page::Admin::SupplierDashboard)