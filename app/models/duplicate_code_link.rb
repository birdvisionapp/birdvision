class DuplicateCodeLink < ActiveRecord::Base
  belongs_to :unique_item_code
  attr_accessible :unique_item_code_id, :code, :user_id_1, :used_at_1, :user_id_2, :used_at_2, :used_count
end
