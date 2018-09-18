class AddRequiredAttributesInTheTables < ActiveRecord::Migration
  def change
    add_column :msps, :is_targeted_offer_enabled, :boolean
    add_column :clients, :is_targeted_offer_enabled, :boolean
    add_column :users, :dob, :date
    add_column :users, :anniversary, :date
  end
end
