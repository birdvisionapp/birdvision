Fabricator(:order) do
  user { Fabricate(:user) }
  address_name "tester"
  address_body "Yerwada"
  address_city "Pune"
  address_state "MH"
  address_zip_code "411006"
  address_landmark "Don Bosco School"
  address_phone "7798987102"
end