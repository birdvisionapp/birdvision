require 'request_spec_helper'

feature "Client Item" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "client price" do

    scenario "should update client price" do
      item = Fabricate(:item)
      item.item_suppliers << Fabricate(:item_supplier, :channel_price => 10_000, :supplier => Fabricate(:supplier))
      client_item = Fabricate(:client_item, :item=>item)
      visit(admin_client_catalog_path(client_item.client.id))
      within("#client_item_#{client_item.id}") do
        click_link("Edit")
      end
      fill_in "client_item_client_price", :with => 50_000
      click_button("Save Item")

      within(".alert") do
        page.should have_content("The Item %s was successfully updated" % client_item.title)
      end
      within("#client_item_#{client_item.id}") do
        page.should have_content('50,000')
        page.should have_content('525')
      end
    end
  end
end

