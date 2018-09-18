class RestoreDefaultsForUserSchemeAttrs < ActiveRecord::Migration
  def change
    change_column_default(:user_schemes, :total_points, 0)
    change_column_default(:user_schemes, :lost_points, 0)
    change_column_default(:user_schemes, :redeemed_points, 0)
  end
end
