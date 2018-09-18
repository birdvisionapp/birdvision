class RemoveInlineTargetsFromUserSchemes < ActiveRecord::Migration
  def club(user_scheme, name)
    Club.includes(:level_club).where("level_clubs.scheme_id = ? AND clubs.name = ?", user_scheme.scheme.id, name).first
  end

  def change
    LevelClub.reset_column_information
    UserScheme.all.each { |user_scheme|
      next unless user_scheme.single_redemption?
      Target.create!(:club => club(user_scheme, "platinum"), :start => user_scheme.platinum_start_target, :user_scheme => user_scheme) if user_scheme.platinum_start_target.present?
      Target.create!(:club => club(user_scheme, "gold"), :start => user_scheme.gold_start_target, :user_scheme => user_scheme) if user_scheme.gold_start_target.present?
      Target.create!(:club => club(user_scheme, "silver"), :start => user_scheme.silver_start_target, :user_scheme => user_scheme) if user_scheme.silver_start_target.present?
    }

  end
end
