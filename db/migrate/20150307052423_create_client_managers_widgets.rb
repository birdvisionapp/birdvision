class CreateClientManagersWidgets < ActiveRecord::Migration
  def change
    create_table :client_managers_widgets do |t|
      t.belongs_to :widget, index: true
      t.belongs_to :client_manager, index: true
      t.string :position      
      t.timestamps
    end
  end
end
