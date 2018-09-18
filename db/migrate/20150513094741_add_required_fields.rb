class AddRequiredFields < ActiveRecord::Migration
  def up
    add_column :targeted_offer_configs , :performance_from , :date
    add_column :targeted_offer_configs , :performance_to , :date
    add_column :targeted_offer_configs , :status , :string ,:default => "pending"
    add_column :targeted_offer_configs , :festival_type , :string
    add_column :to_utilizers , :targeted_offer_config_id , :integer
    add_column :to_applicable_users , :used_at , :date
  end

  def down
  end
end
