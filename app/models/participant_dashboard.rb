class ParticipantDashboard

  def initialize(user)
    @user = user
  end

  def speedometer_data
    with_applicable_user_schemes do |user_scheme|
      if user_scheme.targets.present? && user_scheme.targets.all? { |target| target.start.present? }
        {:id => user_scheme.id,
         :name => user_scheme.scheme.name,
         :start_date => user_scheme.scheme.start_date.to_date.to_formatted_s(:long_ordinal),
         :end_date => user_scheme.scheme.redemption_end_date.to_date.to_formatted_s(:long_ordinal),
         :clubs => user_scheme.targets.collect { |target| {:name => target.club.name, :target_start => target.start} },
         :current_achievements => user_scheme.current_achievements,
         :total_points => user_scheme.total_points}
      end
    end
  end

  def leaderboard_data
    with_applicable_user_schemes do |user_scheme|
      if user_scheme.current_achievements.present?
        current_level_user_schemes = UserScheme.where(:scheme_id => user_scheme.scheme.id, :level_id => user_scheme.level.id).group(:current_achievements).limit(2)

        user_achievements_above_user = extract_user_achievements_hash(current_level_user_schemes.having("current_achievements > ?", user_scheme.current_achievements).order("current_achievements asc")).sort { |a, b| b[:achievements] <=> a[:achievements] }
        current_users_achievements = {name: @user.full_name, achievements: user_scheme.current_achievements, :self => true}
        user_achievements_below_user = extract_user_achievements_hash(current_level_user_schemes.having("current_achievements < ?", user_scheme.current_achievements).order("current_achievements desc"))

        {
            id: user_scheme.scheme.id,
            scheme_name: user_scheme.scheme.name,
            user_achievements: displayable_user_achievements(user_achievements_above_user, user_achievements_below_user, current_users_achievements)

        }
      end
    end
  end

  private
  def extract_user_achievements_hash(user_schemes)
    user_schemes.collect do |current_user_scheme|
      {name: current_user_scheme.user.full_name, achievements: current_user_scheme.current_achievements, :self => false}
    end
  end

  def displayable_user_achievements(user_achievements_above_user, user_achievements_below_user, current_users_achievements)
    user_achievements_above_user.concat([current_users_achievements]).concat(user_achievements_below_user)
  end

  def with_applicable_user_schemes
    collected_data = @user.user_schemes.includes(:targets => :club).browsable.order("schemes.start_date").collect do |user_scheme|
      yield user_scheme
    end
    collected_data.compact
  end
end