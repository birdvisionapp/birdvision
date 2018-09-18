Fabricator(:user_scheme) do
  user
  total_points 10_00_000
  redeemed_points 0
  current_achievements 20_000
  after_build { |user_scheme, attrs|
    assign_level_club(user_scheme, attrs[:level] || "level1", attrs.fetch(:club, "platinum"))
  }
end

Fabricator(:single_redemption_user_scheme, :from => :user_scheme) do
  scheme { Fabricate(:single_redemption_scheme) }
end

Fabricator(:user_scheme_with_targets, :from => :user_scheme) do
  user { Fabricate(:user) }
  transient :level, :club, :targets
  after_build { |user_scheme, attrs|
    assign_level_club(user_scheme, attrs[:level] || "level1", attrs.fetch(:club, "gold"))
    attrs[:targets].collect { |club, target|
      Target.create!(:start => target, :club => Club.with_scheme_and_club_name(user_scheme.scheme, club).first, :user_scheme => user_scheme)
    }
  }
  current_achievements 20_000
end