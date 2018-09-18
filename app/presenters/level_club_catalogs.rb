class LevelClubCatalogs
  include PointRangeCalculator
  include CategoriesToBeDisplayed
  attr_accessor :user_scheme, :msp_id

  def initialize(user_scheme)
    @user_scheme = user_scheme
    @msp_id = @user_scheme.scheme.client.msp_id
  end

  def club_catalogs
    applicable_level_clubs.collect { |level_club|
      ClubCatalog.new(@user_scheme, level_club)
    }
  end

  def club_catalog(id)
    level_club = applicable_level_clubs.find { |level_club| level_club.id.to_s == id.to_s }
    return nil if level_club.nil?
    ClubCatalog.new(@user_scheme, level_club)
  end

  def point_range
    point_range_for(@user_scheme)
  end

  def single_catalog?
    size == 1
  end

  def size
    club_catalogs.size
  end

  def featured
    ClientItem.featured_items(applicable_level_clubs).active_item
  end

  def sub_categories
    get_categories_for(applicable_level_clubs, @msp_id)
  end

  def applicable_level_clubs
    @applicable_level_clubs ||= @user_scheme.applicable_level_clubs
  end

  def sub_categories_for(category)
    sub_categories.select { |c| c.parent_id == category.id }
  end

  def categories
    get_parent_categories_for(applicable_level_clubs, @msp_id)
  end

  def first
    club_catalogs.first
  end
end