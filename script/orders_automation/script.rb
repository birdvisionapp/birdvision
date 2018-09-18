require 'csv'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

log = []
scheme_id = 321 # Scheme to deduct points in participants account
# details is the array of participant order details with address details.
# Sample: [["petronas.7439496646", "69841", "Unit 404, 4th Floor, Vasundara Building, 2/7, Sarat Bose Road, Kolkat  700020", "Kolkata", "Bengal", "700020", "9874421730"], ["petronas.9831024550", "69841", "Unit 404, 4th Floor, Vasundara Building, 2/7, Sarat Bose Road, Kolkat  700020", "Kolkata", "Bengal", "700020", "9874421730"] .... ]
details = []

CSV.foreach("Pointdeductionsheet19May15order406.csv", :encoding => 'windows-1251:utf-8') do |row|
  next if row.size != 7
  details << row
end

details.shift

details.each do |detail|
  ActiveRecord::Base.transaction do
    user = User.where(username: detail[0]).first
    if user.present?
      user_scheme = UserScheme.where(user_id: user.id, scheme_id: scheme_id).first
      if user_scheme.present?
        unless user_scheme.cart.present?
          user_scheme.create_cart
        end
        user_scheme.cart.cart_items.destroy_all if user_scheme.cart.cart_items.present?
	      client_item = ClientItem.with_level_clubs(user_scheme.applicable_level_clubs).active_items.includes(:item).active_item.find_by_id(detail[1])
        if client_item.present?
          user_scheme.cart.add_client_item(client_item)
          address_hash = {address_name: user.full_name, address_body: detail[2], address_city: detail[3], address_state: detail[4], address_zip_code: detail[5], address_phone: detail[6]}
          UserScheme.skip_callback("save", :after, :send_notification)
          order = user_scheme.cart.build_order_for(user_scheme.scheme, address_hash)
          if order.place_order(user_scheme)
            order.order_items.update_all(status: 'delivered', delivered_at: Time.now)
          else
	          log << "#{detail[0]} : #{detail[1]} : #{order.id} - CANNOT PLACE ORDER"
          end
        else
          log << "#{detail[0]} : #{detail[1]} - CLINT ITEM NOT FOUND"
        end
      else
        log << "#{detail[0]} : #{scheme_id} - USER SCHEME NOT FOUND"
      end
    else
      log << "#{detail[0]} - USER NOT FOUND"
    end
  end
end
UserScheme.set_callback("save", :after, :send_notification)
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ LOG: #{log}"
