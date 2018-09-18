module Page
  module Admin
    module ClientCatalogDashboardPage

      def navigate_to_client_catalog_dashboard(client)
        visit admin_draft_items_path
        within('#leftNav') do
          click_link client
        end
      end

      def add_to_client_catalog client_item
        click_on "Add Items"
        table_row_id = find(:xpath, "//td[text()='#{client_item}']/..")[:id]
        within("##{table_row_id}") do
          find(".item_checkbox").set(true)
        end
        click_on "Add To Catalog"
      end

      def remove_from_client_catalog client_item
        id = find(:xpath, "//td[text()='#{client_item}']/..")[:id]
        within("##{id}") do
          click_on "Delete"
        end
      end

      def assign_client_price client_item, client_price
        table_row_id = find(:xpath, "//td[text()='#{client_item}']/..")[:id]
        within("##{table_row_id}") do
          click_link "Edit"
        end
        within('.fields-group') do
          fill_in 'client_item_client_price', :with => client_price
        end
        click_on 'Save Item'
      end

      def navigate_to_scheme_catalog_dashboard(scheme, client)
        navigate_to_client_catalog_dashboard client

        within('#leftNav') do
          click_link scheme
        end
      end

      def add_to_scheme_catalog client_item
        click_on "Add Items"
        table_row_id = find(:xpath, "//td[text()='#{client_item}']/..")[:id]
        within("##{table_row_id}") do
          find(".item_checkbox").set(true)
        end
        click_on "Add To Catalog"
      end
    end
  end
end

World(Page::Admin::ClientCatalogDashboardPage)
