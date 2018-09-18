class RenameSlabLimit < ActiveRecord::Migration
  def change
    rename_column :slabs, :limit, :lower_limit
  end
end
