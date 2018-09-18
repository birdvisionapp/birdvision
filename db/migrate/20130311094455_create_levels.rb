class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |table|
      table.string :name
      table.timestamps
    end
  end
end
