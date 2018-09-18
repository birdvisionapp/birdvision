class AddIndexToSchemesAndLevelClubs < ActiveRecord::Migration
  def change
    add_index :schemes, :id, :unique => true
    add_index :level_clubs, :id, :unique => true
  end
end
