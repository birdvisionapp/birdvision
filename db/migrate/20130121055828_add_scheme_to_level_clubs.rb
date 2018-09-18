class AddSchemeToLevelClubs < ActiveRecord::Migration
  def change
    change_table :level_clubs do |t|
      t.references :scheme
    end
  end
end