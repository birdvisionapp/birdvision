class AddAdminUserIdToDownloadReports < ActiveRecord::Migration
  def change
    add_column :download_reports, :admin_user_id, :integer
    add_index :download_reports, :admin_user_id
  end
end
