class RewardItem < ActiveRecord::Base
  
  attr_accessible :client_id, :name, :scheme_id, :status, :reward_item_points_attributes, :reward_product_catagories_id, :al_part_no, :reward_product_catagory_id

  extend Admin::Reports::RewardProductReport

  # Status
  module Status
    ACTIVE = 'active'
    INACTIVE = 'inactive'
    ALL = [ACTIVE, INACTIVE]
  end

  # Associations
  belongs_to :client
  belongs_to :scheme
  belongs_to :reward_product_catagory
  has_many :reward_item_points, :dependent => :delete_all

  # Validations
  validates :client, :scheme, :name, :presence => true
  validates_uniqueness_of :name, :scope => :scheme_id
  validates :al_part_no, presence: true, if: "client_id == #{ENV['AL_CLIENT_ID'].to_i}"

  accepts_nested_attributes_for :reward_item_points, allow_destroy: true

  # Scopes
  scope :active, -> {where('status = ?', RewardItem::Status::ACTIVE)}
  scope :inactive, -> {where('status = ?', RewardItem::Status::INACTIVE)}
  scope :select_options, -> { select([:id, :name, :scheme_id]) }

  def pack_details
    '' unless reward_item_points.present?
    reward_item_points.map{|pack|
      "#{pack.pack_size_metric} - #{pack.points} Points - #{pack.unique_item_codes.size} Codes"
    }.join(", ").html_safe
  end

  def product_detail
    "#{client.msp_name} - #{client.client_name} - #{scheme.name} - #{name}"
  end
  
end
