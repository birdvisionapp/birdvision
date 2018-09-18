class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :schemes_targeted_offer_configs
    drop_table :reward_items_targeted_offer_configs
    drop_table :targeted_offer_config_incentives
    drop_table :telecom_circles_targeted_offer_configs
    drop_table :user_roles_targeted_offer_configs
  end
end
