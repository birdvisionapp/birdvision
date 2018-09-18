class Slab < ActiveRecord::Base
  has_paper_trail
  attr_accessible :client_reseller, :payout_percentage, :lower_limit
  belongs_to :client_reseller
  validates :payout_percentage, :presence => true, :numericality => {:greater_than => 0, :allow_nil => true}
  validates :lower_limit, :presence => true, :numericality => {:greater_than => 0, :allow_nil => true}
end
