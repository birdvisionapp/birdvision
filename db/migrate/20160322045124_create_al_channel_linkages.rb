class CreateAlChannelLinkages < ActiveRecord::Migration
  def change
    create_table :al_channel_linkages do |t|
      t.belongs_to :user
      t.string :retailer_code
      t.string :ro_code
      t.string :dealer_code
      t.belongs_to :regional_manager
      
      t.timestamps
    end
  end
end
