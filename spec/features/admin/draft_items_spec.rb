require 'request_spec_helper'

feature "Draft Items Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "bulk upload" do

    let!(:supplier) { Fabricate(:supplier) }

    scenario "should show the dropdown to select supplier" do
      visit (import_csv_admin_draft_items_path)
      within("#selectSupplier") do
        page.has_field?("Supplier:")
        page.has_select?('supplier', :options => %W(--- #{supplier.name})).should == true
      end
    end

    scenario "should have link to download template" do
      visit (import_csv_admin_draft_items_path)
      within(".alert-info") do
        page.should have_link "template", :href => "/formats/upload_items_template.csv"
      end
    end

    scenario "should create draft items in bulk" do
      visit(admin_draft_items_path)
      within(".left-nav") do
        page.should have_content("Upload Catalog")
      end
      click_on("Upload Catalog")

      within(".uploadCsv") do
        page.has_field?("CSV:")
      end
      valid_csv_file_path = "#{Rails.root}/spec/fixtures/draft_items.csv"
      attach_file "csv", valid_csv_file_path
      select(supplier.name, :from => 'supplier')
      click_on("Start Upload")

      within(".accordion-toggle") do
        page.should have_content("Draft Item")
        page.should have_content("Success")
      end

      visit(admin_draft_items_path)

      within(".draft_items") do
        page.should have_content("Glass Table")
        page.should have_content(supplier.name)
      end
    end

    scenario "should fail bulk creation for malformed csv" do
      visit(import_csv_admin_draft_items_path)
      attach_file "csv", Rails.root.to_s + "/spec/fixtures/malformed_data.csv"
      select(supplier.name, :from => 'supplier')
      click_on("Start Upload")

      page.find(".accordion-toggle").click

      within(".accordion-inner") do
        page.should have_content("Please use a CSV file in the template provided to upload/update")
      end
    end

    scenario "should not fail bulk creation if records with same listing ids are found" do
      visit(admin_draft_items_path)
      within(".left-nav") do
        page.should have_content("Upload Catalog")
      end
      click_on("Upload Catalog")

      within(".uploadCsv") do
        page.has_field?("CSV:")
      end
      valid_csv_file_path = "#{Rails.root}/spec/fixtures/draft_items_with_duplicates.csv"
      attach_file "csv", valid_csv_file_path
      select(supplier.name, :from => 'supplier')
      click_on("Start Upload")

      within(".accordion-toggle") do
        page.should have_content("Draft Item")
        page.should have_content("Success")
      end

      visit(admin_draft_items_path)

      within(".draft_items") do
        page.should have_content("Samsung S3")
        page.should have_content(supplier.name)
      end
    end


    scenario "should fail bulk creation if file not provided" do
      visit(import_csv_admin_draft_items_path)
      select(supplier.name, :from => "supplier")

      click_on("Start Upload")
      within(".alert-error") do
        page.should have_content("Please choose a file")
      end
    end

    scenario "should fail bulk creation if supplier not provided" do
      visit(import_csv_admin_draft_items_path)
      attach_file "csv", "#{Rails.root}/spec/fixtures/draft_items.csv"

      click_on("Start Upload")

      within(".alert-error") do
        page.should have_content("Please select a Supplier from the dropdown menu when uploading Draft Items")
      end
    end

    scenario "should fail bulk creation if issues in validation are found" do
      visit(import_csv_admin_draft_items_path)
      attach_file "csv", "#{Rails.root}/spec/fixtures/draft_items_with_issues.csv"
      select(supplier.name, :from => "supplier")

      click_on("Start Upload")
      page.find(".accordion-toggle").click

      within(".accordion-inner") do
        page.should have_content("Row Number 2 has the following errors")
      end
      within('.accordion-toggle') do
        page.should have_link "Delete"
      end
    end
  end

  context "update draft item" do
    scenario "should update draft item with new attributes" do
      draft_item = Fabricate(:draft_item)
      category = Fabricate(:category, :title => 'Parent')
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      visit(admin_draft_items_path)

      within(".left-nav") do
        page.should have_content("Upload Catalog")
      end
      navigate_draft_item_edit_page(draft_item)
      select("#{category.title}/#{sub_category.title}", :from => 'draft_item_category_id')
      click_on("Save Draft item")
      within(".alert") do
        page.should have_content("The draft item Samsung s2 was successfully updated.")
      end
      visit(admin_draft_items_path)
      within("#draft_item_#{draft_item.id}") do
        page.should have_content("#{sub_category.title}")
      end

      visit(admin_draft_items_path)
      navigate_draft_item_edit_page(draft_item)

      attach_file "draft_item_image", "#{Rails.root}/spec/fixtures/table.jpg"
      click_on("Save Draft item")
      within(".alert") do
        page.should have_content("The draft item Samsung s2 was successfully updated.")
      end
      find(".image").find("img")['src'].should include(draft_item.reload.image.url(:original, false))
    end

    scenario "should change description of draft item" do
      draft_item = Fabricate(:draft_item)
      visit(admin_draft_items_path)
      navigate_draft_item_edit_page(draft_item)
      fill_in('draft_item_description', :with => "Description of the draft item")
      click_on("Save Draft item")
      page.find(".description").should have_content("Description of the draft item")
    end

    scenario "should cancel the edit of draft item" do
      draft_item = Fabricate(:draft_item)
      visit(admin_draft_items_path)
      navigate_draft_item_edit_page(draft_item)
      click_on("Cancel")
      within('#contentArea') do
        page.should have_content("Draft Items")
      end
    end

    scenario "should not allow editing the supplier" do
      draft_item = Fabricate(:draft_item)

      visit(edit_admin_draft_item_path({:id => draft_item.id}))

      page.find("#draft_item_supplier_name[disabled]").should_not be_nil
      page.find("#draft_item_supplier_name[disabled]").value.should == draft_item.supplier_name
    end

  end

  context "view item" do
    scenario "should display draft item details" do
      draft_item = Fabricate(:draft_item, :category => Fabricate(:category))
      visit(admin_draft_items_path)
      click_on("View")
      within(".draft_item") do
        page.should have_content(draft_item.category.title)
        page.should have_content(draft_item.brand)
        page.should have_content(draft_item.title)
        page.should have_content(draft_item.model_no)
        page.should have_content(draft_item.listing_id)
        page.should have_content(draft_item.specification)
        page.should have_content(draft_item.supplier_name)
        page.should have_content("30,000")
        page.should have_content("32,000")
        page.should have_content(draft_item.supplier_margin)
      end
      within(".image") do
        page.find("img")['src'].should include(draft_item.image.url(:original, false))
      end
    end
  end

  context "delete" do
    scenario "should delete draft items" do
      draft_item = Fabricate(:draft_item, :category => Fabricate(:category))
      visit(admin_draft_items_path)
      click_on("Delete")
      within(".alert") do
        page.should have_content "Draft item was successfully destroyed."
      end
      within(".draft_items") do
        page.should_not have_content(draft_item.title)
      end
    end
  end

  context "lookup and linking" do
    scenario "should display lookup link" do
      draft_item = Fabricate(:draft_item, :category => Fabricate(:category))
      visit(admin_draft_items_path)
      within(".draft_item") do
        page.should have_link("Lookup", :href => admin_draft_item_lookup_path(draft_item.id))
        page.should_not have_link("Edit")
      end
    end

    scenario "should search items in master catalog" do
      draft_item = Fabricate(:draft_item, :category => Fabricate(:category))
      item1 = Fabricate(:item, :title => "apple iphone")
      item2 = Fabricate(:item, :title => "samsung galaxy")

      visit(admin_draft_item_lookup_path(draft_item.id))
      within(".form-search") do
        fill_in("query", :with => "sam")
        click_on("Search")
      end

      within("#search-result") do
        page.should have_content(item2.title)
        page.execute_script 'window.confirm = function () { return true }'
        click_on("Link")
      end


      current_path.should == edit_admin_master_catalog_path(item2.id)
      within(".alert") do
        page.should have_content("Item has been successfully associated with supplier #{draft_item.supplier.name}")
      end
    end
  end

  context "pagination" do
    scenario "should apply pagination for items in master catalog" do
      Fabricate(:draft_item, :title => "first item")
      25.times { Fabricate(:draft_item) }
      visit(admin_draft_items_path(:page => 2))
      page.should have_content("first item")
    end

  end

end

def navigate_draft_item_edit_page(draft_item)
  within("#draft_item_#{draft_item.id}") do
    click_on("View")
  end
  click_on("Edit")
end