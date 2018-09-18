class CreateUserSchemePoints < ActiveRecord::Migration
  def change
    create_table :user_scheme_points do |t|
      t.references :scheme, :null => false
      t.references :user, :null => false
      t.integer :total_points, :default => 0
      t.integer :lost_points, :default => 0
      t.integer :redeemed_points, :default => 0

    end
  end
end
