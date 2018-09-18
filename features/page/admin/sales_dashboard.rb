module Page
  module Admin
    module SalesDashboard

      def verify_participant_present(participant, client, scheme, points_redeemed=nil)
        navigate_to_participants_report(client)
        table_row_id = first(:xpath, "//td[text()='#{participant}']/..")[:id]
        within("##{table_row_id}") do
          page.should have_content("#{client}.#{participant}".downcase)
          page.should have_content(scheme)
          page.should have_content(points_redeemed) if points_redeemed.present?
        end
      end

      def verify_order_present(client, item, status, price, scheme)
        navigate_to_orders_report(client)
        table_row_id = first(:xpath, "//td[text()='#{item}']/..")[:id]
        within("##{table_row_id}") do
          page.should have_content(price)
          page.should have_content(status)
          page.should have_content(scheme)
        end
      end

      def verify_client_present(client)
        table_row_id = first(:xpath, "//td[text()='#{client}']/..")[:id]
        within("##{table_row_id}") do
          page.should have_content(client)
        end
      end

      def navigate_to_participants_report(client)
        table_row_id = first(:xpath, "//td[text()='#{client}']/..")[:id]
        within("##{table_row_id}") do
          click_on "Participants Report"
        end
      end

      def navigate_to_orders_report(client)
        table_row_id = first(:xpath, "//td[text()='#{client}']/..")[:id]
        within("##{table_row_id}") do
          click_on "Orders Report"
        end
      end

      def navigate_to_dashboard
        within "#mainNavigation" do
          click_on "Clients"
        end
      end
    end
  end
end

World(Page::Admin::SalesDashboard)
