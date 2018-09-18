module Csv
  class TargetBuilder
    def initialize(user_scheme, club_target_names, attrs)
      @user_scheme = user_scheme
      @club_target_names = club_target_names
      @attrs = attrs
    end

    def build
      club_targets = @attrs.slice(*@club_target_names)
      update_or_create_targets(@user_scheme, club_targets)
    end

    def update_or_create_targets(user_scheme, target_attrs)
      target_attrs.collect { |attr, val|
        club_name = attr.sub("_start_target", "")
        target = user_scheme.targets.find { |target| target.club.name == club_name }
        target = user_scheme.targets.build(:club => Club.with_scheme_and_club_name(user_scheme.scheme, club_name).first, :user_scheme => user_scheme) if target.nil?

        target.assign_attributes(:start => val) if val.present?
        target
      }
    end

  end
end