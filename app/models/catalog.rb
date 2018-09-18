class Catalog
  attr_accessor :name, :catalog_items

  def initialize(name, catalog_items=[])
    @name = name
    @catalog_items = catalog_items
  end

  def add client_items
    client_items.each { |client_item|
      catalog_item = CatalogItem.new(:client_item => client_item)
      @catalog_items << catalog_item unless contains?(client_item)
    }
  end

  def size
    active_client_items.size
  end

  def active_client_items
    ClientItem.includes(:item).active_items.active_item.for_catalog_items(@catalog_items).order("client_items.client_price DESC") #perf Put this in scope ?
  end

  private
  def contains?(client_item)
    @catalog_items.any? { |catalog_item| catalog_item.client_item == client_item }
  end
end