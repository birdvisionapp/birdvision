module Domain
  module CukeDraftItem
    def upload_draft_item file_name, supplier
      upload_items_from_csv file_name, supplier
    end

    def publish_draft_item draft_item, category
      add_attributes_for draft_item, category
      publish_draft_item_to_master_catalog
    end

    def item_from_csv
      {:item_name => "Samsung Galaxy S2",
       :listing_id => "SGS2",
       :model_no => 223,
       :mrp => 25000,
       :channel_price => 20000
      }
    end
  end
end

World(Domain::CukeDraftItem)