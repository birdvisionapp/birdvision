class AddTotalBudgetToScheme < ActiveRecord::Migration
  def change
    add_column :schemes, :total_budget_in_rupees, :integer
  end
end
