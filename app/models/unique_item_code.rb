class UniqueItemCode < ActiveRecord::Base

  #has_paper_trail

  has_ancestry

  extend Admin::Reports::UniqueProductCodeReport

  # Status
  module State
    ALREADY_USED = 'Already Used'
    EXPIRED = 'Expired'
    INACTIVE_PRODUCT_PACK = 'Inactive Product Pack'
    INACTIVE_PRODUCT = 'Inactive Product'
    INVALID = 'Invalid'
    NOT_ELIGIBLE = 'Not Eligible'
    ALL = [ALREADY_USED, EXPIRED, INACTIVE_PRODUCT_PACK, INACTIVE_PRODUCT, INVALID, NOT_ELIGIBLE]
  end

  # Format
  module PrintFormat
    #EPS = 'eps'
    PDF = 'pdf'
    ALL = [PDF]
  end

  attr_accessible :code, :reward_item_point_id, :user_id, :number_of_codes, :expiry_date, :used_at, :code_packs, :tiers, :pack_tier_config_id, :pack_number, :ancestry
  attr_accessor :number_of_codes, :code_packs, :tiers

  # Associations
  belongs_to :reward_item_point
  belongs_to :user
  belongs_to :pack_tier_config
  has_one :product_code_link

  # Validations
  validates :expiry_date, :presence => true
  validates :number_of_codes, :numericality => true, :allow_blank => true
  #validates :code, :uniqueness => true

  # Scopes
  scope :unused, -> {where('used_at IS NULL')}
  scope :inc, -> { includes(:reward_item_point => {:reward_item => :client}, :pack_tier_config => :user_role) }
  scope :used, -> {where('used_at IS NOT NULL')}
  scope :for_code, lambda {|code| where('lower(code) = ?', code.downcase) }
  scope :no_links, -> {includes(:product_code_link).where(product_code_links: { id: nil })}
  scope :single_tier, -> {where('pack_tier_config_id IS NULL')}

  # CallBacks
  #before_create :generate_unique_code

  def used?
    used_at.present? && user_id.present?
  end

  def expired?
    expiry_date < Date.today
  end

  def inactive_pack?
    reward_item_point.status == RewardItemPoint::Status::INACTIVE
  end

  def inactive_product?
    reward_item_point.reward_item.status == RewardItem::Status::INACTIVE
  end

  def tier_name
    pack_tier_config ? pack_tier_config.tier_name : ''
  end

  def link_details
    "#{product_code_link.linkable.user_role.name} - #{product_code_link.linkable.full_name}" if product_code_link.present?
  end

  class << self
    def generate_unique_codes (product_pack, number_of_codes, expiry_date, code_packs)
      @expiry_date = expiry_date
      @code_packs = code_packs
      @product_pack = product_pack
      if @code_packs >= 1
        init_multi_tier
      else
        pcodes = []
        number_of_codes = number_of_codes.to_i
        ctg = (number_of_codes + (number_of_codes/100)*5)
        (ctg).times { pcodes << rand(10_000_000_000-1_000_000_000)+1_000_000_000 }
        pcodes.uniq!
        existing = UniqueItemCode.where(:code => pcodes).pluck(:code)
        if existing.present?
          pcodes.reject!{|p| existing.include?(p.to_s) }
        end
        pcodes.slice!(number_of_codes..(pcodes.count-1)) if pcodes.count > number_of_codes
        pcodes.each_slice(10000) do |codes_slice|
          inserts = []
          codes_slice.each do |code|
            inserts.push "(#{@product_pack}, '#{code}', '#{@expiry_date}', '#{Time.now}')"
          end
          sql = "INSERT INTO `unique_item_codes` (`reward_item_point_id`, `code`, `expiry_date`, `created_at`) VALUES #{inserts.join(", ")}"
          UniqueItemCode.connection.execute sql
        end
      end
    end

    def init_multi_tier
      configs = PackTierConfig.where(reward_item_point_id: @product_pack).select([:id, :codes])
      @last_config_id = configs.last.id
      confs = []
      configs.each_with_index{|c, indx|
        prev_conf = configs[indx-1] unless indx == 0
        confs << {id: c.id, codes: c.codes, parent_id: prev_conf ? prev_conf.id : nil}
      }
      nested_hash = Hash[confs.map{|e| [e[:id], e.merge(children: [])]}]
      nested_hash.each do |id, item|
        parent = nested_hash[item[:parent_id]]
        parent[:children] << item if parent
      end
      dynamic_config = nested_hash.select { |id, item| item[:parent_id].nil? }.values
      (1..@code_packs).each { |code_pack|
        generate_multi_tier_codes(dynamic_config, code_pack)
      }
    end

    def generate_multi_tier_codes(dyn_config, code_pack, parent = nil)
      dyn_config.each { |config|
        params = {reward_item_point_id: @product_pack, expiry_date: @expiry_date, pack_number: code_pack, pack_tier_config_id: config[:id], ancestry: (parent.present?) ? parent : nil}
        (config[:codes].to_i).times {
          begin
            code = (config[:id] != @last_config_id) ? generate_alphanumeric : rand(10_000_000_000-1_000_000_000)+1_000_000_000
          end while UniqueItemCode.exists?(code: code)
          resource = UniqueItemCode.create(params.merge(code: code))
          generate_multi_tier_codes(config[:children], code_pack, resource.id) if config[:children].present?
        }
      }
    end

    def generate_alphanumeric(size = 6)
      charset = %w{2 3 4 6 7 9 A C D E F G H J K M N P R T V W X Y}
      (0...size).map{ charset.to_a[SecureRandom.random_number(charset.size)] }.join
    end
  end

  private

  def generate_unique_code
    begin
      self.code = build_code
    end while self.class.exists?(code: code)
  end

  def build_code
    rand_alg = (Time.now.to_i + self.reward_item_point.id * self.reward_item_point.reward_item_id * self.reward_item_point.reward_item.scheme_id * self.reward_item_point.reward_item.client_id)
    if (self.reward_item_point.pack_tier_configs.select(:id).count > 0 && self.pack_tier_config_id != self.reward_item_point.pack_tier_configs.select(:id).last.id)
      return generate_alphanumeric
    else
      return rand(9999999999).to_s.center(10, rand(rand_alg).to_s).to_i
    end
  end  
  
end
