class AddTimestampToUserSchemes < ActiveRecord::Migration
  def change
    add_column :user_schemes, :created_at, :datetime
    add_column :user_schemes, :updated_at, :datetime
  end
end
