class CatalogItem < ActiveRecord::Base
  extend Admin::Reports::CatalogReports::SchemeCatalog

  attr_accessible :client_item
  belongs_to :client_item
  belongs_to :catalog_owner, :polymorphic => true
  after_save :reindex_items

  # Scopes
  scope :active_item, where('lower(items.status) = ? AND client_items.deleted = ?', Item::Status::ACTIVE, false)

  has_paper_trail

  private
  def reindex_items
    Sunspot.index!(client_item.reload)
  end
end