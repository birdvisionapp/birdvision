module Page
  module Admin
    module DraftItemDashboard
      def upload_items_from_csv file_name, supplier
        open_upload_catalog_page
        upload_draft_items_from_csv file_name, supplier
      end

      def add_attributes_for draft_item, category
        visit(admin_draft_items_path)
        table_row_id = find(:xpath, "//td[text()='#{draft_item}']/..")[:id]
        within("##{table_row_id}")  do
          click_link("Lookup")
        end
        click_on("Create New Item")
        assign_category_to_draft_item category
        attach_image_for_draft_item
        click_button("Save Draft item")
      end

      def assign_category_to_draft_item category
        select category, :from => "draft_item_category_id"
      end

      def attach_image_for_draft_item
        attach_file("draft_item_image", "#{Rails.root}/features/fixtures/s3.jpg")
      end

      def publish_draft_item_to_master_catalog
        click_link("Publish to Master Catalog")
      end

      def assert_for_suppliers suppliers
        page.should have_select("supplier", :with_options => suppliers)
      end

      def open_upload_catalog_page
        visit(import_csv_admin_draft_items_path)
        click_link("Upload Catalog")
      end

      def upload_draft_items_from_csv file_name, supplier
        attach_file("csv", "#{Rails.root}/features/fixtures/#{file_name}.csv")
        select supplier, :from => "supplier"

        click_button "Start Upload"
      end

    end
  end

end

World(Page::Admin::DraftItemDashboard)