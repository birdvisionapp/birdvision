module Page
  module Admin
    module OrderDashboard

      def navigate_to_order_dashboard
        visit(admin_order_items_path)
      end

      def verify_order_present_for_item(item, user)
        sort_desc_on_column("Placed On")
        table_row_id = first(:xpath, "//td[text()='#{item}']/..")[:id]
        within("##{table_row_id}") do
          page.should have_content(item)
          page.should have_content(user)
        end
      end

      def sort_desc_on_column(column_name)
        click_on(column_name)
        click_on(column_name)
      end

      def change_status_to item, status
        table_row_id = first(:xpath, "//td[text()='#{item}']/..")[:id]
        within("##{table_row_id}") do
          if status == 'Send to supplier'
            click_on 'Send to supplier'
          elsif status == 'Send for delivery'
            click_on 'Send to supplier'
            sleep 5
            click_on 'Send for delivery'
          end
        end
      end
    end
  end

  module Reseller
    module OrderDashboard
      def navigate_to_reseller_order_dashboard client_name
        table_row_id = first(:xpath, "//td[text()='#{client_name}']/..")[:id]
        within("##{table_row_id}") do
          click_on "Orders Report"
        end
      end

      def verify_order_on_reseller_order_dashboard_for_item item, user
        table_row_id = first(:xpath, "//td[text()='#{item}']/..")[:id]
        within("##{table_row_id}") do
          page.should have_content(item)
          page.should have_content(user)
        end
      end
    end
  end
end

World(Page::Admin::OrderDashboard)
World(Page::Reseller::OrderDashboard)