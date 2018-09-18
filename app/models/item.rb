class Item < ActiveRecord::Base
  extend CSVImportable
  extend Admin::Reports::CatalogReports::MasterCatalog

  # Status
  module Status
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [ACTIVE, INACTIVE]
  end

  paginates_per 12
  has_many :cart_items
  attr_accessible :description, :title, :image, :category_id, :brand, :specification, :bvc_price, :margin,
                  :channel_price, :model_no, :item_suppliers, :item_suppliers_attributes, :status, :msp_id

  before_save :create_slug

  belongs_to :category
  has_many :client_items
  has_many :item_suppliers
  has_one :preferred_supplier, :class_name => 'ItemSupplier', :conditions => {:is_preferred => true}

  accepts_nested_attributes_for :item_suppliers

  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :default_url => "/assets/no_image_available.png"

  has_paper_trail

  validates :title, :presence => true
  validates :description, :presence => true, :length => { :maximum => 300 }
  validates :category, :presence => true
  validates :bvc_price, :numericality => {:greater_than => 0}, :allow_nil => true

  # Scopes
  scope :active, where('lower(items.status) = ?', Item::Status::ACTIVE)
  scope :active_items, where("items.bvc_price IS NOT NULL")
  scope :exclude_exist, lambda { |ids| where('items.id NOT IN(?)', ids) if ids.present? }
  scope :client_items_avail, where('client_items.deleted <> ?', true)

  def save_image_from(draft_item)
    self.image = draft_item.image
    save!
    draft_item.destroy
  end

  def to_param
    slug
  end

  def category_title
    self.category.title
  end

  def update_bvc_margin
    self.margin = ((Float(self.bvc_price - self.channel_price)/self.channel_price)*100).round(2) if self.bvc_price.present? and self.channel_price.present?
    self.save
  end

  def update_margin_in_client_catalog
    client_items.active_items.each { |client_item|
      client_item.save!
    }
  end

  def supplier_name
    preferred_supplier.supplier.name
  end

  def channel_price
    preferred_supplier.channel_price if preferred_supplier.present?
  end

  def mrp
    preferred_supplier.mrp if preferred_supplier.present?
  end

  def supplier_names
    item_suppliers.collect { |item_supplier| item_supplier.supplier.name }.compact.join(", ")
  end

  def has_supplier?(supplier)
    self.item_suppliers.find_by_supplier_id(supplier.id).present?
  end

  def self.title_like(title, limit=100, offset=0)
    self.where("items.title like ?", "%#{title}%").limit(limit).offset(offset)
  end

  def self.create_many_from_csv(csv_file, association_id, opts = {})
    self.import_from_file(csv_file, CsvItem.new())
  end

  private

  def create_slug
    self.slug = self.title.parameterize
  end
end
