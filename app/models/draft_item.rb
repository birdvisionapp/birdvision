class DraftItem < ActiveRecord::Base
  extend CSVImportable

  attr_accessible :description, :title, :category_id, :image, :specification, :brand, :model_no,
                  :supplier, :supplier_id, :listing_id, :mrp, :channel_price, :supplier_margin,
                  :geographic_reach, :delivery_time, :available_quantity, :available_till_date, :item_id, :msp_id


  belongs_to :category
  belongs_to :supplier

  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :default_url => "/assets/no_image_available.png"

  validates :title, :presence => true
  validates :listing_id, :presence => true
  validates :model_no, :presence => true
  validates :mrp, :numericality => {:greater_than => 0}
  validates :channel_price, :numericality => {:greater_than => 0}
  validates :description, :length => { :maximum => 300 }
  validates :available_quantity, :numericality => {:only_integer => true, :greater_than => 0}, :allow_blank => true
  validates :supplier, :presence => true
  validates_attachment_content_type :image, {:content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'], :message => "invalid"}

  before_save :calculate_supplier_margin
  before_post_process :image_content_type_valid?

  scope :unpublished, lambda { where(:item_id => nil) }

  def image_content_type_valid?
    !(image_content_type =~ /^image.*/).nil?
  end

  def calculate_supplier_margin
    self.supplier_margin = ((Float(self.mrp - self.channel_price) / self.mrp) * 100).round(2)
  end

  def publish
    item = Item.new(self.attributes.reject! { |column|
      %w(id item_id listing_id mrp geographic_reach delivery_time available_quantity available_till_date supplier_margin channel_price created_at updated_at image_file_name image_content_type image_file_size image_updated_at bvc_price margin supplier_id).include?(column) })
    if item.save
      add_preferred_supplier(item)
      self.update_attributes(:item_id => item.id)
      item.delay.save_image_from(self)
    end
    item
  end

  def published?
    self.item_id.present?
  end

  def link_to(item)
    add_non_preferred_supplier(item)
    self.destroy
  end

  def self.create_many_from_csv(csv_file, supplier_id, opts={})
    supplier = Supplier.find(supplier_id)
    self.import_from_file(csv_file, CsvDraftItem.new(supplier))
  end

  def display_name
    self.title
  end

  def supplier_name
    supplier.name
  end

  private
  def add_preferred_supplier(item)
    add_supplier_to(item, true)
  end

  def add_non_preferred_supplier(item)
    add_supplier_to(item, false)
  end

  def add_supplier_to(item, is_preferred = true)
    item.item_suppliers.create!(:supplier_id => supplier.id, :listing_id => listing_id, :mrp => mrp,
                                :channel_price => channel_price, :supplier_margin => supplier_margin,
                                :geographic_reach => geographic_reach, :delivery_time => delivery_time,
                                :available_quantity => available_quantity, :available_till_date => available_till_date,
                                :is_preferred => is_preferred)
  end

end
