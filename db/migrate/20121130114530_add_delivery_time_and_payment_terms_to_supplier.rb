class AddDeliveryTimeAndPaymentTermsToSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :delivery_time, :string
    add_column :suppliers, :payment_terms, :string
  end
end
