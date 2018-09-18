class CreateIncentives < ActiveRecord::Migration
  def change
    create_table :incentives do |t|
      t.string   "incentive_name"
      t.string   "incentive_description"
      t.string   "incentive_type"
      t.string   "incentive_for"
      t.string   "incentive_detail"
      t.timestamps
    end
  end
end
