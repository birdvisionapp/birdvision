class ClubCatalog
  extend Forwardable
  def_delegators :level_club, :club_name, :club, :name, :catalog, :id
  attr_accessor :user_scheme, :level_club

  def initialize(user_scheme, level_club)
    @user_scheme = user_scheme
    @level_club = level_club
  end

  def to_params
    level_club.to_params
  end

  def ineligible?
    @user_scheme.redemption_active? && @level_club.club.better_than?(@user_scheme.club)
  end

  def items
    catalog.active_client_items
  end

  def featured_items
    items.last(3)
  end
end