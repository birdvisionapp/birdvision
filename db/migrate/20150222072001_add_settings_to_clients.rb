class AddSettingsToClients < ActiveRecord::Migration
  
  def change
    add_column :clients, :settings, :text
  end

end
