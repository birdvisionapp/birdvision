class AddExtraFiledsToToConfigs < ActiveRecord::Migration
  def change
    add_column :targeted_offer_configs, :to_schemes, :string, array: true, default: '{}'
    add_column :targeted_offer_configs, :to_user_roles, :string, array: true, default: '{}'
    add_column :targeted_offer_configs, :to_products, :string, array: true, default: '{}'
    add_column :targeted_offer_configs, :to_telephone_circles, :string, array: true, default: '{}'
  end
end
