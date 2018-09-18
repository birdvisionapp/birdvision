class LevelClub < ActiveRecord::Base
  has_many :catalog_items, :as => :catalog_owner
  has_many :client_items, :through => :catalog_items
  belongs_to :scheme
  belongs_to :level, :validate => true
  belongs_to :club, :validate => true
  attr_accessible :level, :club, :scheme

  validates :scheme, :presence => true
  validates :level, :presence => true
  validates :club, :presence => true

  scope :with_level, lambda { |level| includes(:level).where("levels.name = ?", level) }
  scope :with_club, lambda { |club| includes(:club).where("clubs.name = ?", club) }

  def level_name
    level.name
  end

  def club_name
    club.name
  end

  def name
    "#{level.name.humanize}-#{club.name.humanize}"
  end

  def catalog
    Catalog.new(name, catalog_items)
  end

  def remove client_item
    result = catalog_items.find_by_client_item_id(client_item.id)
    result.destroy if result.present?
    Sunspot.index!(client_item.reload)
    save!
  end

  def can_add? client_items
    in_catalog_of_same_level = client_items.any? do |client_item|
      client_item.level_clubs.any? do |level_club|
        level_club.level == level and level_club.scheme.id == scheme_id
      end
    end

    not in_catalog_of_same_level
  end
end