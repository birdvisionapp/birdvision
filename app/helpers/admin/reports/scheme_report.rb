module Admin::Reports::SchemeReport

  CSV_HEADERS = ["Client Name", "Scheme Name", "Participant ID", "Activation Status", "Activated at", "Participant Status", "Participant Name",
                 "Participant Username", "Total points uploaded", "Total points redeemed", "Final Achievement", "Rewards Redeemed", "Time", "Category"]

  def to_csv options = {}
    CSV_HEADERS.unshift("MSP") if options[:is_super_admin]      
    CSV.generate do |csv|
      csv << CSV_HEADERS
      reporting_data_of_users_for(find(:first), options).each do |row|
        csv << row
      end
    end
  end

  def reporting_data_of_users_for scheme, options
    user_order_price = OrderItem.includes(:order).where(:scheme_id => scheme.id).group("orders.user_id").sum(:price_in_rupees)
    client_name = scheme.client.client_name
    rows = []
    scheme.user_schemes.includes(:user => [{:orders => :order_items}, :user_role]).find_each(:batch_size => 6000) { |user_scheme|
      user = user_scheme.user
      row = [client_name, scheme.name, user.participant_id, user.activation_status, user.activated_at.try(:strftime, "%d-%b-%Y"), user.status.titleize, user.full_name.titleize, user.username, user_scheme.total_points, user_scheme.redeemed_points, user_scheme.current_achievements, user_order_price[user_scheme.user.id].to_i, user_scheme.updated_at.try(:strftime, "%d-%b-%Y %I:%M %p"), user_scheme.user.role_display]
      row.unshift(scheme.client.msp_name) if options[:is_super_admin]
      rows << row
    }
    rows
  end
end
