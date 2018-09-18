class AddUserActivationDate < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :activated_at
    end

    User.reset_column_information
    User.where(:activated_at => nil).find_each do |user|
      user.update_attribute(:activated_at, user.last_sign_in_at)
    end
  end
end
