class AddOrderApprovalToClients < ActiveRecord::Migration
  def change
    add_column :clients, :order_approval, :boolean
    add_column :clients, :order_approval_limit, :integer
  end
end
