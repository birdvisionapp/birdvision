Fabricator(:order_item) do
  client_item
  order
  scheme
  supplier_id { Fabricate(:supplier).id }
end
