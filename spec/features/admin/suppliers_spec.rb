require 'request_spec_helper'

feature "Admin - Suppliers Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "show supplier" do
    scenario "should render Suppliers List page" do
      supplier1 = Fabricate(:supplier, :name=>"Supplier 1")
      supplier2 = Fabricate(:supplier, :name=>"Supplier 2")

      visit(admin_suppliers_path)
      within(".suppliers") do
        page.should have_content supplier1.name
        page.should have_content supplier2.name
      end
    end

    scenario "should render Supplier Details page" do
      supplier = Fabricate(:supplier)
      visit(admin_supplier_path(supplier))
      within(".supplier-details") do
        page.should have_content supplier.name
      end
    end
  end

  scenario "should allow adding new supplier" do
    visit(admin_suppliers_path)
    click_on("New Supplier")

    within("h1") do
      page.should have_content "New Supplier"
    end

    fill_in('Name', :with => 'Test Supplier XYZ123')
    fill_in('Geographic Reach', :with => 'Pan India')
    fill_in('Address', :with => 'Street 1, City, State, India 411111')
    fill_in('Delivery Time', :with => '2-3 days')
    fill_in('Payment Terms', :with => '15 days')
    fill_in('Phone Number', :with => '1234561234')
    fill_in('Description', :with => 'Description of Test Supplier')
    fill_in('Additional Notes', :with => 'do not use this supplier')

    click_on ('Save Supplier')

    within('.alert') do
      page.should have_content("The supplier Test Supplier XYZ123 was successfully created.")
    end

    within('.suppliers') do
      page.should have_content("Test Supplier XYZ123")
    end
  end

  scenario "should not save supplier when name is missing" do
    visit(new_admin_supplier_path)

    click_on ('Save Supplier')

    within('.alert-error') do
      # Note - text ("Can't Be Blank") appears as Sentence Case on page but doesn't work that way in assertion, use lowercase
      page.should have_content("Please enter a supplier name")
    end
  end

  scenario "should allow editing details of existing supplier" do
    supplier = Fabricate(:supplier)
    visit(admin_suppliers_path)
    within ("#supplier_#{supplier.id}") do
      click_on("Edit")
    end

    within("h1") do
      page.should have_content "Edit Supplier"
    end

    fill_in('Name', :with => 'Naya Naam')
    fill_in('Geographic Reach', :with => 'Pan India')
    fill_in('Address', :with => 'Street 1, City, State, India 411111')
    fill_in('Phone Number', :with => '1234561234')
    fill_in('Description', :with => 'Description of Test Supplier')
    fill_in('Additional Notes', :with => 'do not use this supplier')

    click_on ('Save Supplier')

    within('.alert') do
      page.should have_content("The supplier Naya Naam was successfully updated.")
    end

    within('.suppliers') do
      page.should have_content("Naya Naam")
    end

    # TODO - kunal/BA/UX -
    # as the list of suppliers is sorted by IDs and the updated supplier may appear anywhere (or worse, next page)
    # in such case, displaying Show page makes more sense
  end

end
