require 'request_spec_helper'

feature "Catalog Nav" do
  context "catalog nav hierarchy" do
    before :each do
      admin_user = Fabricate(:admin_user)
      login_as admin_user, :scope => :admin_user
    end

    scenario "should display list of clients" do
      client1 = Fabricate(:client, :client_name => 'Smith Inc')
      client2 = Fabricate(:client, :client_name => 'Acme')

      visit(admin_draft_items_path)

      within(".client-catalog") do
        page.should have_link('Smith Inc', {:href => admin_client_catalog_path(client1.id)})
        page.should have_link('Acme', {:href => admin_client_catalog_path(client2.id)})
      end
    end

    scenario "should display links to navigate" do

      visit(admin_draft_items_path)

      within(".system-catalog") do
        page.should have_content('Drafts')
        page.should have_link('Master', {:href => admin_master_catalog_index_path})
      end

    end
  end
end