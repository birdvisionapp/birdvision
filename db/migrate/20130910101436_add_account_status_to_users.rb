class AddAccountStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :status, :string, :default => 'pending'
    add_index :users, :status
    User.all.each do |user|
      if user.activation_status == User::ActivationStatus::NOT_ACTIVATED
        user.update_attributes!(:status => User::Status::PENDING)
      else
        user.update_attributes!(:status => User::Status::ACTIVE)
      end
    end
  end
end
