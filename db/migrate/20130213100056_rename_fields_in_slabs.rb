class RenameFieldsInSlabs < ActiveRecord::Migration
  def up
    rename_column :slabs, :commission_percentage, :payout_percentage
    rename_column :slabs, :slab_limit, :limit
  end
end
