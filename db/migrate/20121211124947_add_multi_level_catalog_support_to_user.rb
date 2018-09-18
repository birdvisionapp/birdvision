class AddMultiLevelCatalogSupportToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_achievements, :integer
    add_column :users, :silver_start_target, :integer
    add_column :users, :gold_start_target, :integer
    add_column :users, :platinum_start_target, :integer
    add_column :users, :club, :string
    add_column :users, :region, :string
    add_column :users, :level, :string
  end
end
