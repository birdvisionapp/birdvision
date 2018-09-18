class MoveTargetDetailsToUserSchemes3 < ActiveRecord::Migration
  def change
    add_column :user_schemes, :club, :string
    add_column :user_schemes, :level, :string
    remove_column :users, :club
    remove_column :users, :level
  end
end
