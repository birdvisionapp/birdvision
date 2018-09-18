class RemoveLostPointsFromUserScheme < ActiveRecord::Migration
  def change
    remove_column :user_schemes, :lost_points
    change_column :user_schemes, :total_points, :integer, :null => false
    change_column :user_schemes, :redeemed_points, :integer, :null => false
  end
end
