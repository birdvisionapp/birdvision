class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |table|
      table.string :name
      table.timestamps
    end
  end
end
