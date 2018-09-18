class CreateClientsTemplates < ActiveRecord::Migration
  def change
    create_table :clients_templates do |t|
      t.integer  "template_id"
      t.integer  "client_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
