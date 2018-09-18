class CreateUserRolesTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :user_roles_targeted_offer_configs do |t|
      t.integer  "user_role_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
