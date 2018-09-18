require 'spec_helper'

describe Category do

  it { should allow_mass_assignment_of :title }
  it { should allow_mass_assignment_of :ancestry }
  it { should_not allow_mass_assignment_of :slug }
  it { should validate_presence_of :title }
  it { should validate_uniqueness_of :title }

  it { should validate_format_of(:title).not_with("Home & Electronics") }
  it { should validate_format_of(:title).with("Home and Electronics") }

  it { should have_many(:items) }
  it { should have_many(:draft_items) }

  it { should be_trailed }

  it "should add slug to item before saving" do
    category = Fabricate(:category, :title => 'abc')
    category.slug.should == 'abc'
  end

  it "should return to_param as slug" do
    Fabricate(:category, :title => 'a b c').to_param.should == "a-b-c"
  end

  it "should include parent title in display name" do
    category = Fabricate(:category)
    sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
    sub_category.display_name.should == "#{sub_category.parent.title}/#{sub_category.title}"
  end

  it "should return title as display name for parent category" do
    category = Fabricate(:category)
    category.display_name.should == category.title
  end

  context "scope" do
    before do
      @home_appliances = Fabricate(:category, :title => "Home Appliances")
      @electronics = Fabricate(:category, :title => "IT")
      @mobile = Fabricate(:sub_category_sofa, :ancestry => @electronics.id, :title => "Mobile")
      @sofa = Fabricate(:sub_category_sofa, :ancestry => @home_appliances.id, :title => "Sofa")
    end
    it "main_categories scope should only return top level categories" do
      Category.main_categories.should == [@home_appliances, @electronics]
    end
    it "sub_categories scope should only return sub categories ordered by the aparent category name" do
      microwaveoven = Fabricate(:sub_category_sofa, :ancestry => @electronics.id, :title => "Microwave Oven")
      Category.sub_categories.should == [@sofa, @mobile, microwaveoven]
    end
  end

  context "search" do
    it "should reindex all associated items if category is renamed" do
      client_item = Fabricate(:client_item)
      category = Fabricate(:category, :items => [client_item.item])

      Sunspot.should_receive(:index)

      category.title = "New fancy title"
      category.save
    end


  end
end
