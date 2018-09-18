class AddMissingForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "level_clubs", "schemes", :name => "level_clubs_scheme_id_fk"
    add_foreign_key "carts", "user_schemes", :name => "carts_user_scheme_id_fk"
  end
end
