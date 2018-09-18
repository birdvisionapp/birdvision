class AddToConfigIdToIncentives < ActiveRecord::Migration
  change_table :incentives do |t|
    t.belongs_to :targeted_offer_configs, index: true
  end
end
