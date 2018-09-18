class Scheme < ActiveRecord::Base

  extend Admin::Reports::SchemeReport
  
  has_paper_trail

  attr_accessible :client_id, :name, :start_date, :end_date, :redemption_start_date, :redemption_end_date, :poster,
                  :hero_image, :total_budget_in_rupees, :single_redemption

  # Scopes
  scope :for_client, lambda {|client_id| where(:client_id => client_id)}
  # scope :select_options, -> { select('schemes.id, schemes.name, schemes.client_id') }
  scope :select_options, -> { select([:id, :name, :client_id]) }
  scope :is_sms_based, where('clients.sms_based', true)

  has_many :catalog_items, :as => :catalog_owner
  has_many :client_items, :through => :catalog_items
  has_many :user_schemes
  belongs_to :client
  has_many :level_clubs
  has_many :levels, :through => :level_clubs, :uniq => true
  has_many :clubs, :through => :level_clubs, :uniq => true
  has_many :scheme_transactions
  has_many :reward_product_catagories
  
  has_attached_file :poster, :default_url => "/assets/scheme_hero_no_image_available.png"
  has_attached_file :hero_image, :default_url => "/assets/scheme_hero_no_image_available.png"

  validates_uniqueness_of :name, :scope => :client_id
  validates :client, :presence => true
  validates :name, :presence => true
  validates :total_budget_in_rupees, :numericality => {:greater_than_or_equal_to => 0}, :allow_blank => true

  validates :start_date, :presence => true, :less_than_equal_to => {:attribute => :end_date}
  validates :end_date, :presence => true
  validates :redemption_start_date, :presence => true, :less_than_equal_to => {:attribute => :redemption_end_date}
  validates :redemption_end_date, :presence => true
  validates :start_date, :less_than_equal_to => {:attribute => :redemption_start_date}
  validates :level_clubs, :presence => true
  validate :level_club_names
  before_save :create_slug

  scope :pre_redemption, -> { where("start_date <= :today AND redemption_start_date > :today", :today => Date.today) }
  scope :redeemable, -> { where("redemption_start_date <= :today AND (redemption_end_date >= :today)", :today => Date.today) }
  scope :expired, -> { where("redemption_end_date < :today ", :today => Date.today) }
  scope :redeemable_or_expired, -> { where("redemption_start_date <= :today", :today => Date.today) }
  scope :for_name, lambda {|name| where('lower(name) = ?', name.downcase) if name.present? }

  def level_club_names
    level_names = level_clubs.collect { |lc| lc.level }.uniq.collect { |c| c.name.strip.downcase }
    club_names = level_clubs.collect { |lc| lc.club }.uniq.collect { |c| c.name.strip.downcase }
    errors.add(:levels, :duplicate) unless level_names.uniq.size == level_names.size
    errors.add(:clubs, :duplicate) unless club_names.uniq.size == club_names.size
  end

  def phase
    redemption_active? ? "Ready For Redemption" : redemption_over? ? "Past" : "Upcoming"
  end

  def redemption_active?
    return false if redemption_start_date > Date.today
    Date.today <= redemption_end_date
  end

  def redemption_over?
    Date.today > redemption_end_date
  end

  def browsable?
    !redemption_over? && start_date <= Date.today
  end

  def display_name
    "#{client.client_name} - #{name}"
  end

  def catalogs
    level_clubs.collect { |level_club| Catalog.new(level_club.name) }
  end

  def catalog
    Catalog.new(name, catalog_items)
  end

  def remove client_item
    catalog_items.find_by_client_item_id(client_item.id).destroy
    level_clubs.each do |level_club|
      level_club.remove(client_item)
    end
    Sunspot.index!(client_item.reload)
    save!
  end

  def active_items
    client_items.active_items.active_item
  end

  def minimum_point
    (active_items.minimum("client_price").to_i * client.points_to_rupee_ratio).to_i
  end

  def maximum_point
    (active_items.maximum("client_price").to_i * client.points_to_rupee_ratio).to_i
  end

  def show_points?
    !single_redemption?
  end

  def create_level_clubs(level_names, club_names)
    return unless level_names.present? && club_names.present?
    levels = level_names.collect { |level| Level.new(:name => level) }
    clubs = club_names.collect.with_index { |club, rank| Club.new(:name => club, :rank => rank) }

    levels.each { |level|
      clubs.each { |club|
        level_clubs.build(:club => club, :level => level, :scheme => self)
      }
    }
  end

  def date_between_redemption?(date, scheme)
    date.between?(scheme.redemption_start_date, scheme.redemption_end_date)
  end

  def create_slug
    self.slug = self.name.parameterize
  end

  def is_1x1?
    level_clubs.size == 1
  end

  def option_format
    [name, id, {'data-parent' => client_id}]
  end

end