class CreateStoreSmsSessions < ActiveRecord::Migration
  def change
    create_table :store_sms_sessions do |t|
    	t.text :sms_id
    	t.string :from_user
    	t.text :response
        t.timestamps
    end
  end
end
