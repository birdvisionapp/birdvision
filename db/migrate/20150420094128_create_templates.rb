class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string   "template_content"
      t.string   "name"
      t.integer  "targeted_offer_type_id"
      t.timestamps
    end
  end
end
