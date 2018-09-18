class Target < ActiveRecord::Base
  has_paper_trail
  attr_accessible :start, :user_scheme, :club

  belongs_to :user_scheme
  belongs_to :club

  validates :start, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true
  validates :user_scheme, :presence => true
  validates :club, :presence => true
end