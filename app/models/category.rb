class Category < ActiveRecord::Base
  attr_accessible :title, :ancestry, :parent_id, :service_charge, :is_service_charge, :delivery_charges, :is_delivery_charges, :msp_id
  attr_accessor :is_service_charge, :is_delivery_charges
  before_save :create_slug

  has_ancestry
  belongs_to :msp
  has_many :items
  has_many :draft_items
  has_paper_trail

  scope :main_categories, -> { where(:ancestry => nil) }
  scope :sub_categories, -> { where(arel_table[:ancestry].not_eq(nil)).reorder("ancestry") }
  scope :select_options_list, select([:id, :title, :slug, :ancestry, :msp_id])
  scope :select_options, select([:id, :title]).order(:title)

  validates :title, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :msp_id}, :format => {:with => /^[-\w ]*$/}
  validates :service_charge, :presence => true, :numericality => {:greater_than => 0.0}, :if => lambda { |c| c.is_service_charge == "1" }
  validates :delivery_charges, :presence => true, :numericality => {:greater_than => 0.0}, :if => lambda { |c| c.is_delivery_charges == "1" }
  after_save :reindex_items

  after_validation :build_service_charge

  def create_slug
    self.slug = self.title.parameterize
  end

  def display_name
    main? ? self.title : "#{self.parent.title}/#{self.title}"
  end

  def main?
    self.parent.nil?
  end

  def to_param
    slug
  end

  def msp_name
    (msp) ? msp.name : "-"
  end

  private
  def reindex_items
    Sunspot.index(ClientItem.joins(:item).where("items.id in (?)", items)) if items.present?
  end

  def build_service_charge
    self.service_charge = '' if self.is_service_charge == "0"
  end
end

