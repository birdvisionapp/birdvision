class AssociateCatalogItemWithLevelClub < ActiveRecord::Migration
  def change
    rename_column :catalog_items, :entity_id, :level_club_id
  end
end
