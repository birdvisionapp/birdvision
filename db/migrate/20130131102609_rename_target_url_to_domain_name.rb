class RenameTargetUrlToDomainName < ActiveRecord::Migration
  def change
    rename_column :clients, :target_url, :domain_name
  end
end
