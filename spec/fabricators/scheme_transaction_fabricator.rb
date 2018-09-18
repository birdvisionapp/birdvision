Fabricator(:scheme_transaction) do
  client
  user
  scheme
  action "credit"
  transaction_type "UserScheme"
  transaction_id "1"
  points "500"
  remaining_points "500"
end

Fabricator(:scheme_transaction_debit, :from => :scheme_transaction) do
  action "debit"
  transaction_type "Order"
  transaction_id "1"
  points "100"
  remaining_points "400"
end

Fabricator(:scheme_transaction_refund, :from => :scheme_transaction) do
  action "refund"
  transaction_type "Order"
  transaction_id "1"
  points "200"
  remaining_points "300"
end