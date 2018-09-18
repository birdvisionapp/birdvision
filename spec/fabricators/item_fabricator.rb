Fabricator(:item) do
  title { sequence(:title) { |i| "Nikon Point and Shoot Camera - #{i}" } }
  description { sequence(:description) { |i| "A 6 megapixel camera with a 12x optical zoom and image stabilization - #{i}" } }
  bvc_price 10_000
  category { Fabricate(:sub_category_camera) }
  margin 25
  after_create { |item| Fabricate(:item_supplier, :item => item, :mrp => 5000, :channel_price => 8_000, :listing_id => "123", :delivery_time => "1-2 days", :geographic_reach => "Ramgarh",
                                  :supplier_margin => 20.0, :supplier => Fabricate(:supplier), :is_preferred => true) }
end

Fabricator(:macbook_pro, from: :item) do
  title { sequence(:title) { |i| "Macbook Pro - #{i}" } }
  description "A Retina display with 5.1 million pixels. An all-flash architecture. Quad-core Intel Core i7 processors. In a design that's just 0.71 inch thin and 4.46 pounds."
  bvc_price 10_000
  category { Fabricate(:sub_category_laptop) }
end

Fabricator(:blue_sofa, from: :item) do
  title "Blue Sofa"
  description "Very very comfortable"
  bvc_price 8_000
  category { Fabricate(:sub_category_sofa) }
end

