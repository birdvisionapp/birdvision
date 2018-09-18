class AddLogoToClients < ActiveRecord::Migration
  def change
    add_column :clients, :logo_file_name, :string
    add_column :clients, :logo_content_type, :string
    add_column :clients, :logo_file_size, :integer
    add_column :clients, :logo_updated_at, :datetime
  end
end
