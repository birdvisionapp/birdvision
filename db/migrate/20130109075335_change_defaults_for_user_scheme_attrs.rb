class ChangeDefaultsForUserSchemeAttrs < ActiveRecord::Migration
  def change
    change_column_default(:user_schemes, :total_points, nil)
    change_column_default(:user_schemes, :lost_points, nil)
    change_column_default(:user_schemes, :redeemed_points, nil)
  end
end
