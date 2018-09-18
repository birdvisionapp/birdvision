# encoding: utf-8
require 'request_spec_helper'


feature "Items listing Spec" do
  before :each do
    @user = Fabricate(:user)
    login_as @user
    @scheme = Fabricate(:scheme, :client => @user.client)
    @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @scheme)
  end

  context "link to Item detail" do
    scenario "should display item details page on clicking item link" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      @scheme.client_items = [client_item]
      level_club_for(@scheme, 'level1', 'platinum').catalog.add([client_item])
      visit(catalog_path_for(@user_scheme))

      find('.item-title a')['title'].should == client_item.item.title
      within(".level1-platinum") {
        click_on(client_item.item.title)
      }
      page.should have_content(client_item.item.title)
      find_link("Add to cart").visible?.should be_true
    end

    scenario "should display item details page on clicking item link" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      @scheme.client_items = [client_item]
      level_club_for(@scheme, 'level1', 'platinum').catalog.add([client_item])
      visit(catalog_path_for(@user_scheme))

      within(".level1-platinum") {
        find("##{client_item.item.id}_image").click
      }
      page.should have_content client_item.item.title
      find_link("Add to cart").visible?.should be_true
    end
  end

  context "pagination" do

    it "should have pagination links " do
      client_items = 15.times.collect {
        Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      }
      @scheme.client_items = client_items
      level_club_for(@scheme, 'level1', 'platinum').catalog.add(client_items)

      visit(catalog_path_for(@user_scheme))
      within('.pagination') do
        page.should_not have_link 'Go'
      end

    end
  end

  context "carousel" do
    it("should show the carousel of 5 items") do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_items = []
      (1..6).each do
        client_items << Fabricate(:client_item, :client_catalog => @user.client.client_catalog,
                                  :item => Fabricate(:item, :category => sub_category))
      end
      @scheme.client_items = client_items
      level_club_for(@scheme, 'level1', 'platinum').catalog.add(client_items)

      visit(catalog_path_for(@user_scheme))


      within("#clientItemCarousel") do
        all(".item").length.should == 5
        all(".item-title a").collect(&:text).should =~ client_items[0..4].collect { |x| x.item.title }
        all(".image-container a").collect { |ele| ele[:href] }.should =~ client_items[0..4].collect { |x| client_item_path(@user_scheme.scheme.slug, x.item) }
      end
    end

    it("should show all the items in carousel if total items are less than 5") do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      client_item3 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))

      @scheme.client_items = [client_item1, client_item2, client_item3]
      level_club_for(@scheme, 'level1', 'platinum').catalog.add([client_item1, client_item2, client_item3])

      visit(catalog_path_for(@user_scheme))


      within("#clientItemCarousel") do
        all(".item").length.should == 3
      end
    end

    it("should not show any items on carousel if no client items exist") do
      #no client_items
      visit(catalog_path_for(@user_scheme))


      within("#clientItemCarousel") do
        all(".item").length.should == 0
      end
    end

  end
end