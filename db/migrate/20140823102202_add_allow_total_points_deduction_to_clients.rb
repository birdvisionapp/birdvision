class AddAllowTotalPointsDeductionToClients < ActiveRecord::Migration
  def change
    add_column :clients, :allow_total_points_deduction, :boolean, :default => false
  end
end
