require 'spec_helper'

describe DraftItem do
  it { should allow_mass_assignment_of :title }
  it { should allow_mass_assignment_of :listing_id }
  it { should allow_mass_assignment_of :description }
  it { should allow_mass_assignment_of :channel_price }
  it { should allow_mass_assignment_of :mrp }
  it { should allow_mass_assignment_of :model_no }
  it { should allow_mass_assignment_of :category_id }
  it { should allow_mass_assignment_of :image }
  it { should allow_mass_assignment_of :specification }
  it { should allow_mass_assignment_of :brand }
  it { should allow_mass_assignment_of :geographic_reach }
  it { should allow_mass_assignment_of :delivery_time }
  it { should allow_mass_assignment_of :available_quantity }
  it { should allow_mass_assignment_of :available_till_date }
  it { should allow_mass_assignment_of :supplier_margin }
  it { should allow_mass_assignment_of :item_id }


  it { should validate_presence_of(:supplier) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:listing_id) }
  it { should validate_presence_of(:model_no) }
  it { should ensure_length_of(:description).is_at_most(300) }

  it { should belong_to(:category) }
  it { should belong_to(:supplier) }
  it { should have_attached_file(:image) }

  it { should validate_numericality_of(:channel_price).with_message(/should be a valid positive number/) }
  it { should validate_numericality_of(:mrp).with_message(/should be a valid positive number/) }
  it "should not allow invalid image content type " do
    expect { Fabricate(:draft_item, :image => File.new("#{Rails.root}/spec/fixtures/items.csv")) }.to raise_error(ActiveRecord::RecordInvalid) #
    expect { Fabricate(:draft_item, :image => File.new("#{Rails.root}/spec/fixtures/table.jpg")) }.to be_true
    expect { Fabricate(:draft_item, :image => File.new("#{Rails.root}/spec/fixtures/table.png")) }.to be_true
    expect { Fabricate(:draft_item, :image => File.new("#{Rails.root}/spec/fixtures/table.gif")) }.to be_true
  end

  # explicitly testing here as we are not validating on presence
  it "should ensure that channel price has positive numeric value" do
    draft_items = [Fabricate.build(:draft_item, :channel_price => -1),
                   Fabricate.build(:draft_item, :channel_price => nil),
                   Fabricate.build(:draft_item, :channel_price => ""),]

    draft_items.each do |draft_item|
      draft_item.valid?.should be_false
      draft_item.errors.first.should == [:channel_price, "Channel price should be a valid positive number"]
    end
  end

  it "should ensure that mrp has valid numeric value" do
    draft_items = [Fabricate.build(:draft_item, :mrp => -1),
                   Fabricate.build(:draft_item, :mrp => nil),
                   Fabricate.build(:draft_item, :mrp => ""),]

    draft_items.each do |draft_item|
      draft_item.valid?.should be_false
      draft_item.errors.first.should == [:mrp, "MRP should be a valid positive number"]
    end
  end


  it "should ensure that available quantity is positive" do
    draft_item = Fabricate.build(:draft_item, :available_quantity => -1)

    draft_item.valid?.should be_false
    draft_item.errors.first.should == [:available_quantity, "Available quantity should be a valid positive number"]
  end


  it "should return display name as item name" do
    draft_item = Fabricate.build(:draft_item, :title => "Mobile")

    draft_item.display_name.should == "Mobile"
  end

  context "publish" do
    it "should publish an item" do
      draft_item = Fabricate(:draft_item, :title => "Mobile 1234 test")

      item = draft_item.publish

      saved_item = Item.find(item.id)
      saved_item.title.should == "Mobile 1234 test"
      saved_item.preferred_supplier.should_not be_nil
      expect { DraftItem.find(draft_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should link to item when published" do
      draft_item = Fabricate(:draft_item, :title => "Mobile 1234 test")
      Item.any_instance.stub_chain(:delay, :save_image_from)

      item = draft_item.publish

      draft_item.reload.item_id.should == item.id
    end

    it "should not publish an item if errors exist" do
      draft_item = Fabricate(:draft_item, :title => "Mobile 1234 test", :category => nil)

      draft_item.publish

      Item.find_by_title(draft_item.title).should be_nil
      DraftItem.find(draft_item.id).should_not be_nil
      draft_item.published?.should be_false
    end

    it "should identify draft item as published" do
      draft_item = Fabricate(:draft_item, :item_id => Fabricate(:item).id)

      draft_item.published?.should be_true
    end

    it "should identify unpublished draft items" do
      published_draft_item = Fabricate(:draft_item, :item_id => Fabricate(:item).id)
      unpublished_draft_item = Fabricate(:draft_item, :item_id => nil)

      DraftItem.unpublished.should == [unpublished_draft_item]
    end
  end

  context "csv upload" do
    it "should check csv import with supplier draft item assignment" do
      csv_file = stub
      supplier = Fabricate.build(:supplier, :id => 10, :geographic_reach => "Pan India", :delivery_time => "1-2 days")
      Supplier.should_receive(:find).with(supplier.id).and_return(supplier)
      DraftItem.should_receive(:import_from_file).with(csv_file, instance_of(CsvDraftItem))
      DraftItem.create_many_from_csv(csv_file, supplier.id)
    end

  end

  context "Supplier margin" do
    it "should  calculate supplier margin" do
      draft_item = Fabricate.build(:draft_item, :available_quantity => 1, :mrp => 32000, :channel_price => 30000)
      draft_item.supplier_margin.should be_nil
      draft_item.save!
      draft_item.supplier_margin.should == 6.25
    end
  end

  context "Linking" do
    it "should copy draft item's supplier details to item in master catalog and delete the draft item" do
      supplier = Fabricate(:supplier)
      draft_item = Fabricate(:draft_item, :supplier => supplier,
                             :channel_price => 90, :mrp => 1000,
                             :geographic_reach => "pan india", :delivery_time => "1 day", :available_quantity => 50,
                             :available_till_date => Date.tomorrow, :listing_id => "abc")
      item = Fabricate(:item)

      draft_item.link_to(item)
      item_supplier = item.item_suppliers.find_by_supplier_id(supplier.id)

      item_supplier.should_not be_nil
      item_supplier.channel_price.should == 90
      item_supplier.supplier_margin.should == 91.0
      item_supplier.mrp.should == 1000
      item_supplier.geographic_reach.should == "pan india"
      item_supplier.delivery_time.should == "1 day"
      item_supplier.available_quantity.should == 50
      item_supplier.available_till_date.should == draft_item.available_till_date
      item_supplier.listing_id.should == "abc"
      item_supplier.is_preferred.should == false

      draft_item.destroyed?.should == true
    end

    it "should raise validation error if same supplier already exists for the item" do
      supplier = Fabricate(:supplier)
      draft_item = Fabricate(:draft_item, :supplier => supplier,
                             :channel_price => 90, :mrp => 1000,
                             :geographic_reach => "pan india", :delivery_time => "1 day", :available_quantity => 50,
                             :available_till_date => Date.tomorrow, :listing_id => "abc")
      item = Fabricate(:item)
      Fabricate(:item_supplier, :item => item, :mrp => 1_20_000, :channel_price => 8_000, :supplier => supplier)

      expect { draft_item.link_to(item) }.to raise_error
    end
  end
end
