require 'request_spec_helper'

feature "Scheme Catalog" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "view" do
    scenario "should display items in catalog" do
      category = Fabricate(:category, :title => 'Parent')
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :item => Fabricate(:item, :category => sub_category))
      scheme = Fabricate(:scheme, :client => client_item.client)
      scheme.catalog.add([client_item])

      visit(admin_scheme_catalog_path(scheme))

      within(".scheme-catalog-items") do
        page.should have_content client_item.item.title
        page.should have_content client_item.item.category.title
        page.should have_content client_item.item.category.parent.title
        page.should have_content client_item.item.preferred_supplier.supplier.name
        page.should have_content('10,000')
        page.should have_content(client_item.item.margin)
        page.should have_content('8,000')
        page.should have_link("Delete")
      end

      #nav menu highlight
      within("li#scheme_#{scheme.id}") do
        page.should have_selector('a.nav-active')
      end

      #avg client margin
      within("#contentArea") do
        page.should have_content("#{scheme.name} Catalog")
        page.should have_content("Average Client Margin:")
        page.should have_content("12.5 %")
      end

      #download catalog
      page.should have_link('Download', {:href => admin_scheme_catalog_path(scheme, :format => "csv")})
    end
  end

end
