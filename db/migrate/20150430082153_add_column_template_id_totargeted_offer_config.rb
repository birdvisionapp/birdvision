class AddColumnTemplateIdTotargetedOfferConfig < ActiveRecord::Migration
  def up
    add_column :targeted_offer_configs , :template_id , :integer 
  end

  def down
  end
end
