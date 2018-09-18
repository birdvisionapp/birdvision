class AddingPolymorphicAssociationBetweenLevelClubAndCatalogItems < ActiveRecord::Migration
  def change
    remove_foreign_key(:catalog_items, :level_club)
    remove_column :catalog_items, :level_club_id

    change_table :catalog_items do |t|
      t.references :catalog_owner, :polymorphic => true
    end
  end
end
