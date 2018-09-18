require 'spec_helper'

describe Admin::DraftItemsController do
  login_admin

  context "routes" do
    it "should route requests correctly" do
      {:get => import_csv_admin_draft_items_path}.should route_to('admin/draft_items#import_csv')
      {:post => upload_csv_admin_draft_items_path}.should route_to('admin/draft_items#upload_csv')
      {:post => admin_draft_item_publish_path(:draft_item_id => 'draft_item_id')}.should route_to('admin/draft_items#publish', :draft_item_id => 'draft_item_id')
      {:get => admin_draft_item_lookup_path(:draft_item_id => 'draft_item_id')}.should route_to('admin/draft_items#lookup', :draft_item_id => 'draft_item_id')
      {:post => admin_draft_item_link_path(:draft_item_id => 'draft_item_id')}.should route_to('admin/draft_items#link', :draft_item_id => 'draft_item_id')
    end
  end

  context "browse draft items" do

    it "should show all unpublished draft items sorted by creation date" do
      draft_item1 = Fabricate(:draft_item, :title => "item1")
      draft_item2 = Fabricate(:draft_item, :title => "item2")
      published_draft_item = Fabricate(:draft_item, :item_id => Fabricate(:item).id)

      get :index

      assigns[:draft_items].should == [draft_item2, draft_item1]
      assigns[:draft_items].should_not include(published_draft_item)
      response.should be_success
    end
  end

  context "lookup and linking" do
    before :each do
      @flipkart = Fabricate(:supplier, :name => "flipkart")

      @draft_item = Fabricate(:draft_item, :title => "samsung s3", :supplier => @flipkart, :mrp => 30_000, :channel_price => 20_000)
      @s2 = Fabricate(:item, :title => "samsung s2 black")
      @s3 = Fabricate(:item, :title => "samsung s3 black")
    end

    it "should search item in master catalog by item title if search query is not present" do
      get :lookup, :draft_item_id => @draft_item.id

      assigns[:draft_item].should == @draft_item
      assigns[:items].should == [@s3]
      response.should be_success
    end

    it "should search item in master catalog by search query if present" do
      get :lookup, :draft_item_id => @draft_item.id, :query => "s2"

      assigns[:draft_item].should == @draft_item
      assigns[:items].should == [@s2]
      response.should be_success
    end

    it "should redirect to admin_draft_items_path if draft_item does not exists" do
      get :lookup, :draft_item_id => "333332222"

      response.should redirect_to admin_draft_items_path
    end

    it "should add supplier from draft_item to existing item in master catalog" do
      post :link, :draft_item_id => @draft_item.id, :item_id => @s3.id

      @s3.reload.item_suppliers.collect { |item_supplier| item_supplier.supplier }.should include @flipkart

      DraftItem.find_by_id(@draft_item.id).present?.should == false

      response.should redirect_to edit_admin_master_catalog_path(@s3.id)
    end

    it "should not add draft_item's supplier details to master catalog item if same supplier already exists for that item" do
      Fabricate(:item_supplier, :item => @s3, :mrp => 31_123, :channel_price => 18_000, :supplier => @flipkart)

      post :link, :draft_item_id => @draft_item.id, :item_id => @s3.id

      DraftItem.find_by_id(@draft_item.id).present?.should == false
      item_supplier = @s3.item_suppliers.find_by_supplier_id(@flipkart.id)
      item_supplier.mrp.should == 31_123
      item_supplier.channel_price.should == 18_000

      response.should redirect_to edit_admin_master_catalog_path(@s3.id)

      flash[:alert] = "Supplier already exists for this item, Deleted the draft item"
    end
  end

  context "Create Master Catalogue" do
    it "should publish an item" do
      draft_item = Fabricate(:draft_item)
      post :publish, "draft_item_id" => draft_item.id
      response.should redirect_to admin_draft_items_path
      flash[:notice].should == "The Item %s has been published to the Master Catalog" % draft_item.title
      Item.count.should == 1
      DraftItem.count.should == 0
    end

    it "should not publish item if errors exist" do
      draft_item = Fabricate(:draft_item, :category => nil)
      post :publish, "draft_item_id" => draft_item.id
      response.should render_template(:show)
      Item.count.should == 0
      DraftItem.count.should == 1
    end

  end

  context "Bulk Upload" do
    before :each do
      @supplier = Fabricate(:supplier)
    end

    it "should not create draft items if supplier is not selected" do

      post :upload_csv, "csv" => Rack::Test::UploadedFile.new("spec/fixtures/draft_items.csv", "text/csv")
      DraftItem.count.should == 0
      flash[:alert].should == "Please select a Supplier from the dropdown menu when uploading Draft Items"
      response.should redirect_to import_csv_admin_draft_items_path
    end

    it "should flash an error if csv is not selected" do

      post :upload_csv
      DraftItem.count.should == 0
      flash[:alert].should == "Please choose a file"
      response.should redirect_to import_csv_admin_draft_items_path
    end

    it "should create draft items in bulk" do
      async_job_mock = mock("async_job_mock")
      delayed_mock = mock("delayed_job_mock")

      csv = Rack::Test::UploadedFile.new("spec/fixtures/draft_items.csv", "text/csv")

      AsyncJob.should_receive(:create).with(:job_owner => "DraftItem", :csv => csv, :status => AsyncJob::Status::PROCESSING).and_return(async_job_mock)

      async_job_mock.should_receive(:valid?).and_return(true)
      async_job_mock.should_receive(:delay).and_return(delayed_mock)
      delayed_mock.should_receive(:execute).with(@supplier.id.to_s)

      post :upload_csv, "csv" => csv, :supplier => @supplier

      flash[:notice].should == "File has successfully been scheduled for upload, please check the upload tab after a while."

      response.should redirect_to admin_uploads_index_path
    end

    it "should not create draft items if csv is of incorrect format" do
      async_job_mock = mock("async_job_mock")
      delayed_mock = mock("delayed_job_mock")

      csv = Rack::Test::UploadedFile.new("spec/fixtures/favicon.ico")

      AsyncJob.should_receive(:create).with(:job_owner => "DraftItem", :csv => csv, :status => AsyncJob::Status::PROCESSING).and_return(async_job_mock)

      async_job_mock.should_receive(:valid?)
      async_job_mock.should_receive(:delay).never
      delayed_mock.should_receive(:execute).never

      post :upload_csv, "csv" => csv, "supplier" => @supplier

      flash[:alert].should == "Please use a CSV file in the template provided to upload Draft Items."

      response.should redirect_to import_csv_admin_draft_items_path

    end
  end
end
