require 'spec_helper'

describe Item do

  it { should allow_mass_assignment_of :title }
  it { should allow_mass_assignment_of :description }
  it { should allow_mass_assignment_of :image }
  it { should allow_mass_assignment_of :category_id }
  it { should allow_mass_assignment_of :model_no }
  it { should allow_mass_assignment_of :specification }
  it { should allow_mass_assignment_of :brand }
  it { should allow_mass_assignment_of :bvc_price }
  it { should allow_mass_assignment_of :margin }


  it { should_not allow_mass_assignment_of :slug }
  it { should_not allow_mass_assignment_of :preferred_supplier }
  it { should have_many(:client_items) }
  it { should have_many(:item_suppliers) }
  it { should belong_to(:category) }
  it { should have_attached_file(:image) }
  it { should have_one(:preferred_supplier) }

  it { should validate_presence_of :description }
  it { should validate_presence_of :title }
  it { should validate_presence_of :category }

  it { should validate_numericality_of(:bvc_price) }
  it { should ensure_length_of(:description).is_at_most(300) }
  it { should be_trailed }

  it "should add slug to item before saving" do
    item = Fabricate(:item, :title => 'abc')
    item.slug.should == 'abc'
  end

  it "should return to_param as slug" do
    Fabricate(:item, :title => 'a b c').to_param.should == "a-b-c"
  end

  it "should return category title for item" do
    item = Fabricate(:item)
    item.category_title.should include("Camera")
  end

  it "should save image for an item and destroy draft item" do
    draft_item = Fabricate(:draft_item, :image => File.new("#{Rails.root}/spec/fixtures/table.jpg"))
    item = Fabricate(:item)
    item.save_image_from(draft_item)
    item.reload.image.url.should include("table.jpg")
    expect { DraftItem.find(draft_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end


  context "delegating methods to preferred supplier" do
    it "should return supplier name for item" do
      item = Fabricate(:item)
      item.supplier_name.should include(item.item_suppliers.first.supplier.name)
    end

    it "should return mrp for item of preferred supplier if present" do
      item = Fabricate.build(:item)
      preferred_supplier = mock
      item.stub(:preferred_supplier).and_return(preferred_supplier)
      preferred_supplier.should_receive(:mrp)
      item.mrp
    end

    it "should return channel_price of preferred supplier if present" do
      item = Fabricate.build(:item)
      preferred_supplier = mock
      item.stub(:preferred_supplier).and_return(preferred_supplier)
      preferred_supplier.should_receive(:channel_price)
      item.channel_price
    end

    it "should return nil for mrp for item with no preferred supplier" do
      item = Fabricate.build(:item)
      preferred_supplier = mock
      preferred_supplier.stub(:present?).and_return(false)
      preferred_supplier.should_not_receive(:mrp)
      item.mrp.should be_nil
    end

    it "should return nil for channel_price for item with preferred supplier" do
      item = Fabricate.build(:item)
      preferred_supplier = mock
      preferred_supplier.stub(:present?).and_return(false)
      preferred_supplier.should_not_receive(:channel_price)
      item.channel_price.should be_nil
    end
  end


  it "should calculate margin before saving" do
    item = Fabricate(:item, :margin => 0)
    item.margin.should == ((Float(item.bvc_price-item.channel_price)/item.channel_price)*100).round(2)
  end

  context "paper_trail versions" do

    it "should create a version of item if base price is updated" do
      item = Fabricate(:item, :bvc_price => 10_000)

      with_versioning do
        item.bvc_price = 20_000
        item.save!
      end

      item.versions.count.should == 1
      item.versions.first.reify.bvc_price.should == 10_000
      item.bvc_price.should == 20_000
    end

  end

  context "search" do
    before :each do
      @item1 = Fabricate(:item, :title => "Samsung s3 black")
      @item2 = Fabricate(:item, :title => "Samsung galaxy note black")
      @item3 = Fabricate(:item, :title => "apple iphone 5 black")
      @item4 = Fabricate(:item, :title => "apple macbook pro")
      @item5 = Fabricate(:item, :title => "google nexus black")
    end

    it "should search items with title like given one" do
      result = Item.title_like("samsung")
      result.should == [@item1, @item2]
    end

    it "should limit search result if provided" do
      result = Item.title_like("black", 2)
      result.size.should == 2
      result.should include @item1
      result.should include @item2
    end

    it "should offset search result if provided" do
      result = Item.title_like("black", 2, 2)
      result.size.should == 2
      result.should include @item3
      result.should include @item5
    end
  end

  it "should tell if supplier already exists" do
    flipkart = Fabricate(:supplier, :name => "flipkart")
    infibeam = Fabricate(:supplier, :name => "infibeam")
    s2 = Fabricate(:item, :title => "samsung s2 black")
    Fabricate(:item_supplier, :item => s2, :mrp => 30_000, :channel_price => 18_000, :supplier => flipkart)

    s2.has_supplier?(flipkart).should == true
    s2.has_supplier?(infibeam).should == false
  end


  it "should return preferred supplier" do
    item = Fabricate(:item)
    flipkart = Fabricate(:supplier, :name => "flipkart")
    infibeam = Fabricate(:supplier, :name => "infibeam")

    # remove the default preferred supplier assigned to item by fabricator
    item_supplier = item.item_suppliers.first
    item_supplier.is_preferred = false
    item_supplier.save!

    Fabricate(:item_supplier, :item => item, :supplier => flipkart, :is_preferred => true)
    Fabricate(:item_supplier, :item => item, :supplier => infibeam, :is_preferred => false)

    item.reload.preferred_supplier.supplier.should == flipkart
  end
end
