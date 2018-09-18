class Level < ActiveRecord::Base
  attr_accessible :name
  has_one :level_club

  validates :name, :presence => true
  scope :with_scheme_and_level_name, lambda { |scheme, level| includes(:level_club).where("level_clubs.scheme_id = ? AND levels.name = ? ", scheme.id, level) }

end