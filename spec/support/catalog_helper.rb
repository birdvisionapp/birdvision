module CatalogHelper
  def level_club_for(scheme, level, club)
    scheme.level_clubs.with_level(level).with_club(club).first
  end

  def with_pagination_override(clazz, num, &block)
    old_val = clazz.default_per_page
    clazz.paginates_per num
    begin
      block.call
    ensure
      clazz.paginates_per old_val
    end
  end
end