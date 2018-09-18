require 'request_spec_helper'

feature "Client Catalog" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "catalog nav hierarchy" do
    scenario "should display client catalog" do
      client_item = Fabricate(:client_item)
      visit(admin_master_catalog_index_path)

      within(:css, ".nav-list.client-catalog") do
        click_link(client_item.client.client_name)
      end

      within("li#client_#{client_item.client.id}") do
        page.should have_selector('a.nav-active')
      end

      within("#contentArea") do
        page.should have_content("#{client_item.client.client_name} Catalog")
        page.should have_content("Average Client Margin:")
        page.should have_content("12.5 %")
      end
      within(".client-catalog-items") do
        page.should have_content(client_item.item.title)
        page.should have_content(client_item.item.category.title)
        page.should have_content('10,000')
        page.should have_content(client_item.item.margin)
        page.should have_content('8,000')
        page.should have_link('Edit')
        page.should have_link("Delete")
      end

      within(".actions") do
        page.should have_link("Add Items")
        page.should have_link('Download', {:href => admin_client_catalog_path(client_item.client, :format => "csv")})
      end
    end

    scenario "should apply pagination for client items in master catalog" do

      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
      Fabricate(:client_item, :item => Fabricate(:item, :title => "samsung"), :client_catalog => emerson.client_catalog, :client_price => 1_15_001)

      10.times { Fabricate(:client_item, :client_catalog => emerson.client_catalog, :client_price => 1_15_001) }

      visit(admin_client_catalog_path(:id => emerson))
      within('.actions .go_to_page') do
        fill_in 'page', :with => 2
        click_on 'Go'
      end

      page.should have_content("samsung")
    end

    scenario "should remove item from client catalog" do
      client_item = Fabricate(:client_item, :deleted => false)
      other_client_item = Fabricate(:client_item, :deleted => false, :item => Fabricate(:blue_sofa),
                                    :client_catalog => client_item.client_catalog)
      visit(admin_master_catalog_index_path)
      within(:css, ".nav-list.client-catalog") do
        click_link(client_item.client.client_name)
      end
      within("#client_item_#{client_item.id}") do
        click_link 'Delete'
      end
      page.should have_content("The Item #{client_item.item.title} has been removed from the #{client_item.client.client_name} Client Catalog")
      within(".client-catalog-items") do
        page.should_not have_content(client_item.item.title)
      end
    end

    scenario "should update margin of client item if client price for an item changes in master catalog edit of the corresponding item" do
      category = Fabricate(:category, :title => 'Parent')
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)

      macbook_pro = Fabricate(:macbook_pro, :bvc_price => 1_10_000,
                              :category => sub_category)

      macbook_pro.item_suppliers << Fabricate(:item_supplier, :mrp => 1_20_000, :channel_price => 80_000, :supplier => Fabricate(:supplier))

      emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)

      Fabricate(:client_item, :client_catalog => emerson.client_catalog, :item => macbook_pro, :client_price => 1_15_001)

      visit(admin_master_catalog_index_path)
      first(:link, "Edit").click
      fill_in 'item[item_suppliers_attributes][0][channel_price]', :with => 90_000
      click_on 'Save Item'

      click_link emerson.client_name

      within('.client_item') do
        page.should have_content '1337.51'
      end
    end

    context "Edscenario " do
      scenario "should edit the client item" do
        category = Fabricate(:category, :title => 'Parent')
        sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)

        macbook_pro = Fabricate(:macbook_pro, :bvc_price => 1_10_000, :category => sub_category)


        emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
        macbook_pro.item_suppliers << Fabricate(:item_supplier, :mrp => 1_20_000, :channel_price => 80_000, :supplier => Fabricate(:supplier))

        Fabricate(:client_item, :client_catalog => emerson.client_catalog, :item => macbook_pro, :client_price => 1_15_001)

        visit(admin_master_catalog_index_path)
        click_link emerson.client_name
        within('.client_item') do
          click_link 'Edit'
        end
        fill_in 'client_item_client_price', :with => '2000000'
        click_on 'Save Item'
        within('.client_item') do
          page.should have_content '20,00,000'
          page.should have_content '24900'
        end
      end
    end
  end
end
