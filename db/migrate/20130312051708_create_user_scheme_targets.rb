class CreateUserSchemeTargets < ActiveRecord::Migration
  def change
    create_table :targets do |table|
      table.integer :start
      table.references :user_scheme
      table.references :club
      table.timestamps
    end
    add_foreign_key :targets, :user_schemes, :name => "targets_user_scheme_id_fk"
    add_foreign_key :targets, :clubs, :name => "targets_club_id_fk"
  end
end
