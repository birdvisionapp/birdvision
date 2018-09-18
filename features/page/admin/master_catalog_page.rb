module Page
  module Admin
    module MasterCatalogPage

      def assign_bvc_price bvc_price, draft_item
        visit(admin_master_catalog_index_path)
        table_row_id = find(:xpath, "//td[text()='#{draft_item}']/..")[:id]
        within("##{table_row_id}") do
          click_link("Edit")
        end
        fill_in "item_bvc_price", :with => bvc_price
        click_button("Save Item")
      end

    end
  end

end

World(Page::Admin::MasterCatalogPage)