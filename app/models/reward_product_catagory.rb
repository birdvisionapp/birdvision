class RewardProductCatagory < ActiveRecord::Base
  
  belongs_to :client
  belongs_to :scheme
  has_many :reward_items
  attr_accessible :client_id, :scheme_id, :category_name, :category_description
  
  validates :client, :scheme, :category_name, :category_description, :presence => true
    
  scope :for_scheme, lambda {|scheme_id| where(:scheme_id => scheme_id)}
  scope :select_categories, -> { select('reward_product_catagories.id, reward_product_catagories.category_name, reward_product_catagories.scheme_id') }
  
  def option_format
    [category_name, id, {'data-parent' => scheme_id}]
  end
end