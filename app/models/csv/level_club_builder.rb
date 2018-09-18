module Csv
  class LevelClubBuilder
    def initialize(user_scheme, attrs)
      @user_scheme = user_scheme
      @attrs = attrs
    end

    def build
      attrs = @attrs.slice("level", "club")
      @user_scheme.scheme.is_1x1? ? assign_level_club_for_1x1(@user_scheme) : assign_level_club_for_mxn(@user_scheme, attrs)
      @user_scheme
    end

    private
    def assign_level_club_for_1x1(user_scheme)
      user_scheme.level = user_scheme.scheme.level_clubs.first.level
      user_scheme.club = user_scheme.scheme.level_clubs.first.club
    end

    def assign_level_club_for_mxn(user_scheme, level_club_attrs)
      user_scheme.level = Level.with_scheme_and_level_name(user_scheme.scheme, level_club_attrs['level']).first || Level.new(nil) if level_club_attrs['level'].present?
      user_scheme.club = Club.with_scheme_and_club_name(user_scheme.scheme, level_club_attrs['club']).first || Club.new(nil) if level_club_attrs['club'].present?
    end

  end
end
