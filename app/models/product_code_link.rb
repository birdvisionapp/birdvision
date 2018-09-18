class ProductCodeLink < ActiveRecord::Base

  extend Admin::Reports::ProductCodeLinkReport

  attr_accessible :linkable_id, :linkable_type, :unique_item_code_id

  # Associations
  belongs_to :linkable, :polymorphic => true
  belongs_to :unique_item_code

  # Scopes
  scope :unused, -> {where('unique_item_codes.used_at IS NULL')}


end
