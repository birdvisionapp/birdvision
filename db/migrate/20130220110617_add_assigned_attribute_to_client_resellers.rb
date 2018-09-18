class AddAssignedAttributeToClientResellers < ActiveRecord::Migration
  def change
    add_column :client_resellers, :assigned, :boolean, :default => true
  end
end
