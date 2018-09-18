module Page
  module Admin
    module ClientManagerDashboard

      def verify_dashboard_contents info
        within "#mainNavigation" do
          click_on "Dashboard"
        end
        within('.schemes') do
          page.should have_content info['active_schemes']
        end
        within('.scheme-budget') do
          page.should have_content info['active_schemes_budget_total']
        end
        within('.participants') do
          page.should have_content info['activated_user_count']
        end
        if info['order_count'].present?
          within('.orders') do
            page.should have_content info['order_count']
          end
        end
      end

      def navigate_to_catalog_dashboard client
        within "#mainNavigation" do
          click_on "Catalog"
        end
        within "#leftNav" do
          click_link client
        end
      end

      def navigate_to_scheme_catalog_of scheme
        within "#mainNavigation" do
          click_on "Catalog"
        end

        within "#leftNav" do
          click_link scheme
        end
      end

      def navigate_to_participants_dashboard
        within "#mainNavigation" do
          click_on "Participants"
        end
      end

      def navigate_to_schemes_dashboard
        within "#mainNavigation" do
          click_on "Schemes"
        end
      end

      def navigate_to_clients_dashboard
        within "#mainNavigation" do
          click_on "Clients"
        end
      end

      def verify_scheme_visible scheme_name
        navigate_to_schemes_dashboard
        within('.schemes') do
          page.should have_content scheme_name
        end
      end

      def verify_participant_listed participant_name, client
        within('.users') do
          table_row_id = first(:xpath, "//td[text()='#{participant_name}']/..")[:id]
          within("##{table_row_id}") do
            page.should have_content client
          end
        end
      end

      def verify_item_in_client_catalog client, item
        within(:css, ".nav-list.client-catalog") do
          click_link(client)
        end
        within('.client-catalog-items') do
          verify_item_present?(item)
        end
      end

      def verify_scheme_catalog_visible item
        within('.scheme-catalog-items') do
          verify_item_present?(item)
        end
      end

      def verify_item_present?(item)
        page.should have_content item['name']
        page.should have_content item['category']
        page.should have_content item['client_price']
        page.should have_content item['parent_category']
      end

    end
  end
end

World(Page::Admin::ClientManagerDashboard)
