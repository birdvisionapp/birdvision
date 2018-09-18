require 'spec_helper'

describe ItemSupplier do
  it { should allow_mass_assignment_of :mrp }
  it { should allow_mass_assignment_of :channel_price }
  it { should allow_mass_assignment_of :supplier_id }
  it { should allow_mass_assignment_of :listing_id }

  it { should allow_mass_assignment_of :geographic_reach }
  it { should allow_mass_assignment_of :delivery_time }
  it { should allow_mass_assignment_of :available_quantity }
  it { should allow_mass_assignment_of :available_till_date }
  it { should allow_mass_assignment_of :supplier_margin }

  it { should validate_presence_of :mrp }
  it { should validate_numericality_of(:mrp)}
  it { should validate_presence_of :channel_price }
  it { should validate_numericality_of(:channel_price)}
  it { should be_trailed }

  it "should validate uniqueness of supplier_id scoped to an item" do
    item = Fabricate(:item)
    supplier = Fabricate(:supplier)
    Fabricate(:item_supplier, :item=>item, :supplier=>supplier)

    duplicate_item_supplier = Fabricate.build(:item_supplier, :item=>item, :supplier=>supplier)

    expect {
      item.item_suppliers << duplicate_item_supplier
      item.save!
    }.to raise_error ActiveRecord::RecordInvalid
  end
end
