class RemoveClientIdFromLevelClubs < ActiveRecord::Migration
  def up
    remove_foreign_key(:level_clubs, :client)
    remove_column :level_clubs, :client_id
  end
end
