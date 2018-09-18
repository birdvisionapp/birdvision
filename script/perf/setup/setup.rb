require "#{Rails.root}/db/seeds.rb"
PaperTrail.enabled = false

supplier_count = 3
client_count = 4
scheme_count = 3
user_count = (ENV["USERS"] || 2000).to_i
items_in_master_catalog_count = (ENV["ITEMS"] || 100).to_i
batch_size = 10

def random_list(list, count=1)
  count.times.collect { random(list) }.uniq
end

def random(list)
  list[rand(list.length)]
end

def random_number(num)
  rand(num) + 1
end

supplier_count.times do |i|
  Supplier.create!(name: "Perf-Supplier - #{i}", address: "Pune", phone_number: "02012345678", geographic_reach: "West India", delivery_time: "3-4 days", description: "default supplier", additional_notes: "notes", payment_terms: "10 days")
end

client_count.times do |i|
  p "[clients] batch #{i}"
  client = Client.create!(:client_name => "Perf-Client - #{i}", :contact_email => "bvc-perf-client@mailinator.com", :points_to_rupee_ratio => 2, :code => "pc#{i}")
  scheme_count.times { |scheme_no|
    scheme = Scheme.new(:name => "Perf Big Bang Dhamaka #{scheme_no}", :client_id => client.id, :start_date => Date.today - 30.days,
                        :end_date => Date.yesterday, :redemption_start_date => Date.today, :redemption_end_date => Date.today + 30.days, :single_redemption => false)
    scheme.create_level_clubs(%w(level1 level2), %w(platinum gold))
    scheme.save!
  }
end

categories = Category.all
suppliers = Supplier.all
clients = Client.all

(items_in_master_catalog_count/batch_size).times do |batch|
  p "[items] batch #{batch}"
  ActiveRecord::Base.transaction do

    batch_size.times do |i|
      item = Item.create!(:category_id => random(categories).id, :title => "Perf-#{i} #{Faker::Lorem.sentence(3)}",
                          :description => Faker::Lorem.sentence(25, true),
                          :bvc_price => random_number(1_00_000))
      item.item_suppliers.create!(:is_preferred => true, :supplier_margin => 16, :supplier_id => random(suppliers).id, :mrp => 45_000, :channel_price => 38_000)
      random_list(clients, random_number(client_count * 2)).each do |client|
        client_item = ClientItem.create!(:deleted => false, :client_price => random_number(1_00_000), :client_catalog_id => client.client_catalog.id, :item_id => item.id)
        client.schemes.each do |scheme|
          scheme.catalog.add([client_item])
          random_list(scheme.level_clubs, scheme.level_clubs.size).each { |level_club|
            level_club.catalog.add([client_item])
          }
        end
      end
    end
  end
end

black_tie = Item.where(:title => 'Black Tie').first #default item added to all catalogs.
Client.all.each { |client|
  black_tie_client_item = ClientItem.create!(:deleted => false, :client_price => random_number(1_00), :client_catalog_id => client.client_catalog.id, :item_id => black_tie.id)
  client.schemes.each { |scheme|
    scheme.catalog.add([black_tie_client_item])
    scheme.level_clubs.each { |level_club|
      level_club.catalog.add([black_tie_client_item])
    }
  }
}

perf_scheme = Client.where(:client_name => 'Perf-Client - 1').first.schemes.first
schemes = perf_scheme.client.schemes - [perf_scheme]
schemes_count = schemes.count
(user_count/batch_size).times do |current_batch|
  p "[users] batch #{current_batch}"
  ActiveRecord::Base.transaction do
    batch_size.times do |i|
      id = current_batch*batch_size + i
      user = User.create!(:participant_id => "perf_#{id}", :client => perf_scheme.client, :email => "bvc_perf#{id}@mailinator.com", :password => "password", :password_confirmation => "password", :full_name => "perf user #{id}", :mobile_number => "1234567890")
      associate_targets_and_achievements({:user_id => user.id, :total_points => 2_00_00_000, :scheme_id => perf_scheme.id}, 'level1', 'gold')
      random_list(schemes, random_number(schemes_count * 2)).each do |scheme|
        associate_targets_and_achievements({:user_id => user.id, :total_points => 2_00_00_000, :scheme_id => scheme.id}, 'level1', 'gold')
      end
    end
  end
end
