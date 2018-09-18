class AddPayoutEndDateForClientReseller < ActiveRecord::Migration
  def up
    add_column :client_resellers, :payout_end_date, :date
  end
end
