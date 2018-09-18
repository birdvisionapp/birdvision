class MoveTargetDetailsToUserSchemes2 < ActiveRecord::Migration
  def change
    add_column :user_schemes, :current_achievements, :integer
    add_column :user_schemes, :silver_start_target, :integer
    add_column :user_schemes, :gold_start_target, :integer
    add_column :user_schemes, :platinum_start_target, :integer
    #add_column :user_schemes, :club, :string
    #add_column :user_schemes, :level, :string
    add_column :user_schemes, :region, :string

    remove_column :users, :current_achievements
    remove_column :users, :silver_start_target
    remove_column :users, :gold_start_target
    remove_column :users, :platinum_start_target
    #remove_column :users, :club
    #remove_column :users, :level
    remove_column :users, :region
  end
end
