class AddSlugToClientItem < ActiveRecord::Migration
  def change
    add_column :client_items, :slug, :string
  end
end
