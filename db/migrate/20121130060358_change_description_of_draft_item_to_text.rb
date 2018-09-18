class ChangeDescriptionOfDraftItemToText < ActiveRecord::Migration
  def change
    change_column :draft_items, :description, :text
  end
end
