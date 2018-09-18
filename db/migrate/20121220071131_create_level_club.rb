class CreateLevelClub < ActiveRecord::Migration
  def change
    create_table :catalog_items do |t|
      t.integer :entity_id, :null => false
      t.references :client_item, :null => false
    end
    create_table :level_clubs do |t|
      t.references :client, :null => false
      t.string :level_name
      t.string :club_name
    end
  end
end
