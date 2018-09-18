class AddTargetUrlToClient < ActiveRecord::Migration
  def change
    add_column :clients, :target_url, :string
  end
end
