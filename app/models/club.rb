class Club < ActiveRecord::Base
  has_one :level_club
  attr_accessible :name, :rank

  validates :name, :presence => true
  validates :rank, :numericality => {:only_integer => true}, :presence => true

  scope :with_scheme_and_club_name, lambda { |scheme, club| includes(:level_club).where("level_clubs.scheme_id = ? AND clubs.name = ? ", scheme.id, club) }

  def better_than?(club)
    return true if club.nil?
    self.rank > club.rank
  end
end