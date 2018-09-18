class MoveTargetDetailsToUserSchemes < ActiveRecord::Migration
  def change
    rename_table :user_scheme_points, :user_schemes
    #add_column :user_schemes, :current_achievements, :integer
    #add_column :user_schemes, :silver_start_target, :integer
    #add_column :user_schemes, :gold_start_target, :integer
    #add_column :user_schemes, :platinum_start_target, :integer
    #add_column :user_schemes, :club, :string
    #add_column :user_schemes, :region, :string
    #add_column :user_schemes, :level, :string
    #
    #remove_column :user_schemes, :current_achievements
    #remove_column :user_schemes, :silver_start_target
    #remove_column :user_schemes, :gold_start_target
    #remove_column :user_schemes, :platinum_start_target
    #remove_column :user_schemes, :club
    #remove_column :user_schemes, :region
    #remove_column :user_schemes, :level
  end
end
