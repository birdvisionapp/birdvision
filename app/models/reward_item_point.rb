class RewardItemPoint < ActiveRecord::Base
  
  attr_accessible :pack_size, :points, :reward_item_id, :status, :metric, :pack_tier_configs_attributes

  extend Admin::Reports::RewardProductPackReport

  # Status
  module Status
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [ACTIVE, INACTIVE]
  end

  # Metric
  module Metric
    L = 'l'
    ML = 'ml'
    KL = 'kl'
    G = 'g'
    MG = 'mg'
    KG = 'kg'
    UNITS = 'units'
    ALL = [L, ML, KL, G, MG, KG, UNITS]
  end

  # Associations
  belongs_to :reward_item
  has_many :unique_item_codes, :dependent => :delete_all
  has_many :pack_tier_configs, :dependent => :destroy
  has_many :al_transactions


  # Validations
  validates :pack_size, :metric, :points, :presence => true
  #validates :reward_item_id, :presence => true
  validates :points, :numericality => true, :allow_blank => true
  validates_uniqueness_of :pack_size, :scope => :reward_item_id

  accepts_nested_attributes_for :pack_tier_configs, allow_destroy: true

  # Scopes
  [:active, :inactive].each do |status|
    scope status, where(status: status)
  end
  scope :select_options, -> { select([:id, :reward_item_id, :pack_size, :metric]) }

  def product_detail
    "#{reward_item.name if reward_item.present?} - #{pack_size_metric}"
  end

  def pack_size_metric
    "#{pack_size} #{metric.upcase}"
  end

  def product_code_detail
    detail = []
    used = unique_item_codes.used.select(:id).size
    unused = unique_item_codes.unused.select(:id).size
    detail << "Used: #{used}" if used > 0
    detail << "Not Used: #{unused}" if unused > 0
    detail
  end

  def link_codes(options = {})
    inserts = []
    total_codes = options.values.inject(0){|a,b|a.to_i+b.to_i}
    code_ids = []
    self.unique_item_codes.unused.single_tier.no_links.find_each(:batch_size => 1000) do |code, index|
      break if code_ids.count == total_codes
      code_ids << code.id
    end
    options.each do |user_id, number_of_codes|
      codes_branch = code_ids.slice!(0, number_of_codes.to_i)
      if codes_branch.present?
        codes_branch.each do |code|
          inserts.push "(#{code}, 'User', #{user_id}, '#{Time.now}')"
        end
      end
    end
    inserts.each_slice(10000) do |codes_slice|
      sql = "INSERT INTO `product_code_links` (`unique_item_code_id`, `linkable_type`, `linkable_id`, `created_at`) VALUES #{codes_slice.join(", ")}"
      ProductCodeLink.connection.execute sql
    end
  end

  def single_tier?
    pack_tier_configs.size == 0
  end

  def option_format
    [product_detail, id, {'data-parent' => reward_item.scheme_id}]
  end

end
