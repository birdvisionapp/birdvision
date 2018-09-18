class RenamePointsToRatioColumnForClients < ActiveRecord::Migration
  def change
    rename_column :clients, :points_to_rupee_ration, :points_to_rupee_ratio
  end
end
