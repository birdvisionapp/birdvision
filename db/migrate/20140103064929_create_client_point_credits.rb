class CreateClientPointCredits < ActiveRecord::Migration
  def up
    create_table :client_point_credits do |t|
      t.integer :client_id
      t.integer :points
      t.datetime :created_at
    end
    add_index :client_point_credits, :client_id
    remove_column :clients, :paid_points
    add_column :clients, :opening_balance, :integer, :default => 0
  end

  def down
    drop_table :client_point_credits
    add_column :clients, :paid_points, :integer, :default => 0
    remove_column :clients, :opening_balance
  end
end
