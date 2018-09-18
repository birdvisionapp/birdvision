class CreateClientCustomizations < ActiveRecord::Migration
  def change
    create_table :client_customizations do |t|
      t.belongs_to :client
      t.boolean :coupen_code_enabled
      t.boolean :sign_up_enabled
      t.boolean :additional_info_enabled
      t.string :field_title
      t.string :field_subtitle
      t.belongs_to :user_role
      
      t.timestamps
    end
  end
end
