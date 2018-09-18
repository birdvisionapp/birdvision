class AddMissingIndices2 < ActiveRecord::Migration
  def change
    add_index(:users, :participant_id)
    add_index(:items, :title)
  end
end
