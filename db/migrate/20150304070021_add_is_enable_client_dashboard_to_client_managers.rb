class AddIsEnableClientDashboardToClientManagers < ActiveRecord::Migration
  def change
    add_column :client_managers, :is_client_dashboard_unabled, :boolean, default: false
  end
end
