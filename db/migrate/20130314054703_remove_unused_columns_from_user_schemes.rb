class RemoveUnusedColumnsFromUserSchemes < ActiveRecord::Migration
  def change
    remove_column :user_schemes, :platinum_start_target
    remove_column :user_schemes, :gold_start_target
    remove_column :user_schemes, :silver_start_target

    remove_column :user_schemes, :level_name
    remove_column :user_schemes, :club_name
  end
end
