require "request_spec_helper"

feature "Master Catalog page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "index of master catalog" do
    scenario "should display all the items in master catalog" do
      category = Fabricate(:category)
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category.id)
      item = Fabricate(:item, :category => sub_category_sofa)
      expected_bvc_margin = 25.0
      visit(admin_master_catalog_index_path)
      ['Supplier Margin', 'Actions', 'Clients', 'Base Margin(%)', 'Base Price(Rs.)', 'Item Id', 'Item Name', 'Category', 'Sub Category',
       'All Suppliers', 'Pref. Supplier', 'Channel Price(Rs.)', 'MRP(Rs.)', 'Average Base Margin'].each { |element|
        page.should have_content(element)
      }
      [item.id, item.title, item.category.parent.title, item.category.title, item.supplier_names,
       '8,000', '5,000', '10,000', expected_bvc_margin].each { |element|
        page.should have_content(element)
      }
      page.should have_link('Download', {:href => admin_master_catalog_index_path(:format => "csv")})
    end

    scenario "should apply pagination for items in master catalog" do
      Fabricate(:item, :title => "first item")
      10.times { Fabricate(:item) }
      visit(admin_master_catalog_index_path(:page => 2))
      page.should have_content("first item")
    end
  end
  context "Base Price" do

    scenario "should add Base Price for an item" do
      category = Fabricate(:category)
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category.id)
      item = Fabricate(:item, :category => sub_category_sofa)
      visit(admin_master_catalog_index_path)
      within("#item_#{item.id}") do
        click_link("Edit")
      end

      [item.title, 'Brand', 'Model No.', item.specification, 'Listing ID', 'Delivery Time', 'Geographic Reach',
       'Available Quantity', 'Available Till Date', 'Channel Price', 'Supplier Margin'].each { |element|
        page.should have_content(element)
      }
      find("#item_description").value.should == item.description
      fill_in 'Base Price', :with => 16_000
      click_on 'Save Item'

      within("#item_#{item.id}") do
        page.should have_content('8,000')
        page.should have_content('16,000')
        page.should have_content('100')
      end
    end

    scenario "should cancel the edit of base price" do
      category = Fabricate(:category)
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category.id)

      item = Fabricate(:item, :category => sub_category_sofa)
      visit(admin_master_catalog_index_path)
      within("#item_#{item.id}") do
        click_link("Edit")
      end
      page.should have_content(item.title)
      click_on 'Cancel'
      page.should have_content('Master Catalog')
    end
  end
end