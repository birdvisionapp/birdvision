require 'spec_helper'

describe Admin::Reports::CatalogReports do

  context "master catalog reports" do
    include Admin::Reports::CatalogReports::MasterCatalog
    before :each do
      category = Fabricate(:category)
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category.id)
      @item1 = Fabricate(:item, :category => sub_category_sofa)
      @item2 = Fabricate(:item, :category => sub_category_sofa)
      @client_item = Fabricate(:client_item, :item => @item1)
    end
    let(:csv) { to_csv }

    def all
      [@item1]
    end

    it "should have csv headers" do
      csv.should include(["Item Id", "Item Name", "Category", "Sub Category", "All Suppliers", "Pref. Supplier", "Pref. Supplier - Listing Id",
                          "Pref. Supplier - Delivery Time", "Pref. Supplier - Geographic Reach", "Pref. Supplier - Available Quantity",
                          "Pref. Supplier - Available till Date", "Channel Price(Rs.)", "MRP(Rs.)", "Base Price(Rs.)", "Base Margin(%)",
                          "Supplier Margin(%)", "Clients"].join(","))
    end

    it "should generate csv" do
      csv.should include([@item1.id.to_s, @item1.title, @item1.category.parent.title, @item1.category.title, @item1.supplier_names,
                          @item1.preferred_supplier.supplier.name, @item1.preferred_supplier.listing_id, @item1.preferred_supplier.delivery_time,
                          @item1.preferred_supplier.geographic_reach, @item1.preferred_supplier.available_quantity.to_s,
                          @item1.preferred_supplier.available_till_date.to_s,
                          "8000.0", "5000.0", "10000.0", "25.0", "20.0", @client_item.client_catalog.client.client_name].join(","))
    end
  end

  context "client reports" do
    before :each do
      @category = Fabricate(:category)
      @sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => @category.id)
      @client_item1 = Fabricate(:client_item, :item => Fabricate(:item, :category => @sub_category_sofa))
      @client_item1.item.preferred_supplier.update_attributes!(:supplier_margin => 10.000)
      @scheme = Fabricate(:scheme, :client => @client_item1.client_catalog.client, :name => "Khatarnak Scheme")
      @scheme.catalog.add([@client_item1])
      @client_item2 = Fabricate(:client_item, :item => Fabricate(:item, :category => @sub_category_sofa))
    end

    context "Client Catalog" do
      include Admin::Reports::CatalogReports::ClientCatalog

      def all
        [@client_item1]
      end

      it "should have csv headers for super_admin by default" do
        to_csv.should include(["Item Id", "Item Name", "Category", "Sub Category", "Pref. Supplier", "MRP(Rs.)", "Channel Price(Rs.)",
                                              "Supplier margin(%)", "Base Price(Rs.)", "Base Margin(%)", "Client Price(Rs.)", "Client Margin(%)", "Points", "Schemes"].join(","))
      end

      it "should generate csv for super_admin by default" do
        to_csv.should include([@client_item1.item.id.to_s, @client_item1.item.title, @category.title, @sub_category_sofa.title,
                                              @client_item1.item.preferred_supplier.supplier.name,
                                              "5000.0", "8000.0", "10.0", "10000.0", "25.0", "9000.0", "12.5", "90000", "Khatarnak Scheme"].join(","))
      end

      it "should have csv headers for client_manager" do
        to_csv("client_manager").should include(["Item Id", "Item Name", "Category", "Sub Category", "MRP(Rs.)", "Client Price(Rs.)", "Points", "Schemes"].join(","))
      end

      it "should generate csv for client_manager" do
        to_csv("client_manager").should include([@client_item1.item.id.to_s, @client_item1.item.title, @category.title, @sub_category_sofa.title,
                                                 "5000.0", "9000.0", "90000", "Khatarnak Scheme"].join(","))
      end
    end

    context "scheme catalog" do
      include Admin::Reports::CatalogReports::SchemeCatalog
      let(:csv) { to_csv }

      def all
        @scheme.catalog.catalog_items
      end

      it "should have csv headers for super admin" do
        csv.should include(["Item Id", "Item Name", "Category", "Sub Category", "Pref. Supplier", "MRP(Rs.)", "Channel Price(Rs.)",
                            "Supplier margin(%)", "Base Price(Rs.)", "Base Margin(%)", "Client Price(Rs.)", "Client Margin(%)", "Points"].join(","))
      end

      it "should generate csv for super admin" do
        csv.should include([@client_item1.item.id.to_s, @client_item1.item.title, @category.title, @sub_category_sofa.title,
                            @client_item1.item.preferred_supplier.supplier.name,
                            "5000.0", "8000.0", "10.0", "10000.0", "25.0", "9000.0", "12.5", "90000"].join(","))
        end
      it "should have csv headers for client manager" do
        to_csv("client_manager").should include(["Item Id", "Item Name", "Category", "Sub Category", "MRP(Rs.)", "Client Price(Rs.)", "Points"].join(","))
      end

      it "should generate csv for client manager" do
        to_csv("client_manager").should include([@client_item1.item.id.to_s, @client_item1.item.title, @category.title, @sub_category_sofa.title,
                            "5000.0", "9000.0", "90000"].join(","))
      end
    end

  end

end
