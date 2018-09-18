class ClientItem < ActiveRecord::Base
  extend Admin::Reports::CatalogReports::ClientCatalog

  paginates_per 12

  belongs_to :item
  belongs_to :client_catalog
  has_one :client, :through => :client_catalog
  has_many :catalog_items
  has_many :schemes, :through => :catalog_items, :uniq => true, :source => :catalog_owner, :source_type => 'Scheme'
  has_many :level_clubs, :through => :catalog_items, :uniq => true, :source => :catalog_owner, :source_type => 'LevelClub'
  attr_accessible :item_id, :client_catalog_id, :client_price, :margin, :deleted
  validates :item_id, :presence => true
  validates :client_price, :numericality => {:greater_than => 0}, :allow_nil => true

  has_paper_trail

  before_save :calculate_margin
  before_save :create_slug

  scope :featured_items, lambda { |level_clubs| with_level_clubs(level_clubs).active_items.includes(:item, {:client_catalog => :client}).order("client_items.margin desc").limit(5) }
  scope :with_level_clubs, lambda { |level_clubs| includes(:level_clubs).where("level_clubs.id in (?)", level_clubs) }
  scope :active_items, lambda { available.where("client_price > 0") }
  scope :available, lambda { where(:deleted => false) }
  scope :for_catalog_items, lambda { |catalog_items| includes(:catalog_items).where("catalog_items.id in (?)", catalog_items) }
  scope :active_item, where('lower(items.status) = ? AND client_items.deleted = ?', Item::Status::ACTIVE, false)
  scope :exclude_exist, lambda { |ids| where('client_items.id NOT IN(?)', ids) if ids.present? }

  searchable do
    integer :client_id do
      client_catalog.client.id
    end

    integer :scheme_ids, :multiple => true do
      schemes.map { |scheme| scheme.id }
    end

    integer :level_club_ids, :multiple => true do
      level_clubs.map { |level_club| level_club.id }
    end
    text :description do
      item.description
    end
    text :title do #, :as => :title_textp do
      item.title
    end
    integer :points do
      price_to_points
    end
    string :category do
      item.category.present? ? item.category.title : nil
    end
    string :parent_category do
      item.category.parent.present? ? item.category.parent.title : nil
    end
    boolean :deleted
  end

  def to_param
    slug
  end

  def calculate_margin
    self.margin = ((Float(self.client_price - self.item.channel_price)/self.item.channel_price)*100).round(2) if self.client_price.present? and self.item.channel_price.present?
  end

  def create_slug
    self.slug = self.item.slug
  end

  def title
    self.item.title
  end

  def price_to_points
    (self.client_price * self.client.points_to_rupee_ratio).to_i if self.client.points_to_rupee_ratio.present? and self.client_price.present?
  end

  def soft_delete
    update_attributes(:deleted => true)
    catalog_items.each(&:delete)
    Sunspot.index!(self)
  end

  def client
    client_catalog.client
  end

  def client_id
    client_catalog.client.client_id
  end

  def item_redeemable?(user_scheme)
    return false unless user_scheme.can_redeem?
    level_clubs.includes(:club).where("level_id = ? AND clubs.rank <= ?", user_scheme.level.id, user_scheme.club.rank).present?
  end

  def self.redeemable_ids(user_scheme)
    return [] unless user_scheme.club.present?
    joins(:level_clubs => :club).where("level_id = ? AND clubs.rank <= ?", user_scheme.level.id, user_scheme.club.rank).pluck("client_items.id").to_a
  end
end