require 'csv'

filename = 'production_14thMarch2015.csv' # participant orders and address details to read
rows = []
CSV.foreach("production_12thMarch2015/#{filename}") do |row|
  rows << row
  puts "Invalid COLUMNS: #{row.size}" if row.size != 7
end
rows.shift

rows.each_slice(50).each.with_index(1) do |row_set, index|
  file = File.open("production_orders_#{index}", "w") # Save ruby multi-dimentional array to copy in the console and execute orders automation script.
  file.write(row_set)
end
