class SmsBasedController < ApplicationController

  before_filter :find_client, :only => :validate_message

  def validate_message
     check_duplicate_sms = check_duplicate_session(params)
     if check_duplicate_sms == false
      return_text = sms_body(:invalid_format_sms_based)
      begin
        client = {client: @client.client_name}
        mobile_number = params['From'].to_i
        if (mobile_number.present? && params['To'].present?) && @client.present?
          body_item = params['Body']
          body_text = clean_sms(params['Body'])
          bal = 'BAL'
          body_item = body_item.downcase.to_s
          if body_text =~ /#{bal}/i
            return_text = check_account_balance(mobile_number)
          elsif body_item.include? 'g'
           if find_user != nil
            account_bal = check_account_balance_sms(mobile_number)
            if account_bal.gsub(/[^0-9]/, '').to_i > 0
              return_text = is_item_code_present(body_item)
           else
              return_text = sms_body(:low_balance, client)
           end
          else
              return_text = sms_body(:not_register_user, client)
          end
          elsif body_item.include? 'p'
             otp_check = body_item.scan( /\d+$/ ).first.to_i
             return_text = check_otp(otp_check)
          else
            product_codes = clean_sms(params['Body'], '', '0-9A-Za-z[,]').split(',')
            if product_codes.present?
              product_codes.reject!{|c| c.blank? }
              product_codes.map!(&:strip)
              product_codes.uniq!
            end
            return_text = (product_codes.size > 5) ? sms_body(:sms_based_do_not_send_more_codes) : validate_unique_codes(mobile_number, product_codes)
          end
        end
      rescue Exception => e
        Rails.logger.warn "Failed SMS Based Response: #{e.message}"
      end
      store_first_sms_details(params, return_text)
      puts "++++++++++========================================================="
      puts return_text
      puts "++++++++++========================================================="
      render :text => return_text, :content_type => 'text/plain'
    else
      puts "=========================================================="
      puts "Having Duplicate SmsSid"
      puts check_duplicate_sms
      puts "=========================================================="
      render :text => check_duplicate_sms, :content_type => 'text/plain'
   end
  end


  private
  
  def is_item_code_present(item_code)
   item_code_clear = item_code.scan( /\d+$/ ).first.to_i
   @user = User.where('mobile_number = ? and client_id = ?', params['From'].to_i, @client.id).first
   @user_scheme = @user.user_schemes.browsable#(&:current_achievements)
   @user_scheme.each do |user_scheme|
      @client_item = ClientItem.with_level_clubs(user_scheme.applicable_level_clubs).active_items.available.active_item.includes(:item).where(client_items: {item_id: item_code_clear, client_catalog_id: @client.client_catalog_id}).first
      break if @client_item.present?
   end
   if @client_item.present?
     bal = is_enough_balance(@client_item)
     if bal != 0
       if @client.allow_otp? && @client.sms_based?
        @add_to_cart = @user_scheme.first.cart.add_client_item_sms(@client_item, @client)
        if @add_to_cart != false
           @user.save!
           send_otp_to_user(bal)
        else
          time = seconds_to_time(@client.otp_code_expiration)
          otp_exp_time = {time: time}
          return sms_body(:item_already_in_cart, otp_exp_time)  
        end
      else
        client = {client: @client.client_name}
        return sms_body(:user_sms_redemption, client)
      end
       else
        client = {client: @client.client_name}
        return sms_body(:low_balance, client)
      end      
   else
      client = {client: @client.client_name}
      return sms_body(:invalid_item_id, client)
   end
  end

  def seconds_to_time(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
  end
  
  def is_enough_balance(client_item)
   @extra_charge = ExtraCharges.new(client_item)
   user_balance = check_account_balance_sms(params['From'].to_i)
   user_balance = user_balance.gsub(/[^0-9]/, '').to_i
   ex_charges = @extra_charge.total + client_item.price_to_points
   if user_balance > ex_charges
     return ex_charges
   else
     return 0
   end
  end

  def send_otp_to_user(balance)
   if @client.allow_otp? && @client.exotel_linked_number?
     user = @user.send_one_time_password_sms(balance)
     otp_code = user.otp_code
     bal = balance
     UserMailer.delay.send_one_time_password(user, otp_code) if user.client.allow_otp_email? && user.email.present?
     otp_message = {otp_code: otp_code, client: @client.client_name, balance: bal, client_number: @client.exotel_linked_number}
     return sms_body(:one_time_password_sms, otp_message)
   end
    client = {client: @client.client_name}
    return sms_body(:user_sms_redemption, client)
  end

  def check_otp(otp)
    return nil unless find_user.client.allow_otp?
      otp_check = find_user.check_one_time_password(otp)
      if otp_check.present?
          create_order
      else
        client = {client_number: @client.exotel_linked_number, client: @client.client_name}
        return sms_body(:otp_not_match, client)
      end
  end

  def create_order
    @user_scheme = find_user.user_schemes.first
    @user_order = User.find(@user_scheme.user_id).orders.where('address_name != ? and address_body != ?', "Please contact participant", "Please contact participant").last
   unless @user_order.blank?
    order_detail = { "address_name"=> @user_order.address_name, "address_body"=> @user_order.address_body, "address_landmark"=> @user_order.address_landmark, "address_city"=> @user_order.address_city, "address_state"=> @user_order.address_state, "address_zip_code"=> @user_order.address_zip_code, "address_phone"=>"#{find_user.mobile_number}", "redemption_type" =>"sms" }
   else
    order_detail = { "address_name"=>"Please contact participant", "address_body"=>"Please contact participant", "address_landmark"=>"Please contact participant", "address_city"=>"Please contact participant", "address_state"=>"Please contact participant", "address_zip_code"=> "000000", "address_phone"=>"#{find_user.mobile_number}", "redemption_type" =>"sms" }
   end
    @order = @user_scheme.cart.build_order_for(@user_scheme.scheme, order_detail)
    if @order.place_order(@user_scheme)
      total_points = @order.total
      OrderMailer.delay.point_redemption(@order, @user_scheme.scheme, @order.order_items, total_points) if @order.user.email.present?
       point_order_confirmation = {order_id: @order.order_id,  total_points: total_points, client: @order.user.client.client_name}
       return sms_body(:point_order_confirmation, point_order_confirmation)
    else
      return sms_body(:not_able_to_create_order)
    end
  end

  def find_client
    @client ||= Client.where(sms_number: params['To'].to_i).select([:id, :client_name, :code, :client_catalog_id, :allow_otp, :exotel_linked_number, :otp_code_expiration, :sms_based]).first
  end

  def find_user
    User.where('mobile_number = ? and client_id = ?', params['From'].to_i, @client.id).first
  end

  def validate_unique_codes(mobile_number, codes)
    code_labels = []
    product_codes = []
    users = @client.users.for_mobile_number(mobile_number).select('users.id, users.status')
    codes.each do |code|
      unique_code = UniqueItemCode.includes(:product_code_link, :reward_item_point => :reward_item).where('lower(unique_item_codes.code) = ? AND reward_items.client_id = ?', code.downcase, @client.id).select('unique_item_codes.used_at, unique_item_codes.user_id, unique_item_codes.expiry_date').first
      label = UniqueItemCode::State::INVALID
      if unique_code.present?
        unless unique_code.product_code_link && unique_code.product_code_link.linkable.mobile_number.to_i == mobile_number
          label = get_product_code_label(unique_code)
          if duplicate_linkage?(unique_code)
            if users.present?
              update_report = update_duplicate_linkage_for_registered(users.first, unique_code)
              if update_report and label == "Already Used"
                label = "#{unique_code.reward_item_point.points} Points"
                product_codes << unique_code
              elsif update_report
                product_codes << unique_code           
              end
            else
              if label == "Already Used"
                 label = "#{unique_code.reward_item_point.points} Points"
              end
              product_codes << unique_code
            end
          # elsif !UniqueItemCode::State::ALL.include?(label)
          #   product_codes << unique_code
          else
            product_codes << unique_code unless UniqueItemCode::State::ALL.include?(label)
          end
        else
          label = UniqueItemCode::State::NOT_ELIGIBLE
        end
      end
      code_labels << "#{code}: #{label}"
    end
    users = @client.users.for_mobile_number(mobile_number).select('users.id, users.status')
    params = {client: @client.client_name}
    unless users.present?
      sms_template = :sms_based_first_time_participant_invalid_codes if @client.id != 261
      sms_template = check_code_status_abbott(code_labels, @client, product_codes) if @client.id == 261
      if product_codes.present?
        user = @client.users.new
        user.participant_id, user.mobile_number = mobile_number, mobile_number
        user.registration_type = :sms
        user.save(:validate => false)
        update_unique_codes(user.id, product_codes.map(&:id))
        update_duplicate_linkage_for_new_registration(user.id, product_codes.map(&:id))
        if @client.id != 261
          sms_template = :sms_based_first_time_participant
        else
          #sms_template = :abbott_first_message
          sms_template = check_for_abbott_client_logic(product_codes, @client, user)
        end
      end
      return sms_body(sms_template, params.merge!(codes_state: code_labels.join(', ')))
    end
    if users.map(&:status).include?(User::Status::INACTIVE)
      return sms_body(:account_deregistered_sms_based, params)
    end
    users.each do |user|
      if !user.is_retailer?
       client_check = check_for_abbott_client(@client)
        if client_check == false
          if code_labels.count > 1
            code_labels_points, code_label_lables = refactor_code_labels(code_labels)
          end
          #sms_template = (user.status == User::Status::PENDING) ? :sms_based_first_time_participant_invalid_codes : :sms_based_registered_participant_invalid_codes
          puts "-------------"
          if user.status == User::Status::PENDING
           if code_labels.count > 1
             sms_template = :sms_based_first_time_participant_invalid_more_codes
           else
             sms_template = :sms_based_first_time_participant_invalid_codes
           end
          else
            if code_labels.count > 1
              sms_template = :sms_based_registered_participant_invalid_more_codes
            else
              sms_template = :sms_based_registered_participant_invalid_codes
            end
          end
          puts "-------------"
          
          if product_codes.present?
            update_unique_codes(user.id, product_codes.map(&:id))
            User.build_user_scheme(user, product_codes) unless user.status == User::Status::PENDING
            #sms_template = (user.status == User::Status::PENDING) ? :sms_based_first_time_participant : :sms_based_registered_participant
            puts "-------------"
            if user.status == User::Status::PENDING
             if code_labels.count > 1
              if code_label_lables.empty?
                sms_template = :all_codes_are_valid_first_time_participant
              else
                sms_template = :some_valid_some_invalid_code_first_time_participant
              end
             else
              sms_template = :sms_based_first_time_participant
             end
            else
              if code_labels.count > 1
               if code_label_lables.empty?
                sms_template = :all_codes_are_valid
               else
                sms_template = :some_valid_some_invalid_code
               end
              else
                sms_template = :sms_based_registered_participant
              end
            end
            params.merge!(points: product_codes.map(&:reward_item_point).map(&:points).sum)
          end

          if code_labels.count > 1
            return sms_body(sms_template, params.merge!(codes_state: code_labels.join(', '), balance: user.total_redeemable_points, code_send_invalid: code_label_lables.join(", "), valid_code_count: code_labels_points.sum))
          else 
            return sms_body(sms_template, params.merge!(codes_state: code_labels.join(', '), balance: user.total_redeemable_points))
          end
        else
          if product_codes.present?
            update_unique_codes(user.id, product_codes.map(&:id))
            User.build_user_scheme(user, product_codes) unless user.status == User::Status::PENDING
            check_template = check_for_abbott_client_logic(product_codes, @client, user)
            return sms_body(check_template)
          else
            sms_template = check_code_status_abbott(code_labels, @client, product_codes)
            return sms_body(sms_template)
          end
        end
      end
    end
    return sms_body(:invalid_account_sms_based, params)
  end

  def sms_body(template, options = {})
    I18n.interpolate(App::Config.sms_templates[template], options)
  end

  def check_account_balance(mobile_number)
    users = @client.users.includes(:user_schemes).for_mobile_number(mobile_number).select('users.id, users.status')
    params = {client: @client.client_name}
    unless users.present?
      return sms_body(:invalid_account_sms_based, params)
    end
    if users.map(&:status).include?(User::Status::PENDING)
      return sms_body(:account_pending_sms_based, params)
    end
    if users.map(&:status).include?(User::Status::INACTIVE)
      return sms_body(:account_deregistered_sms_based, params)
    end
    if users.size == 1
      template = :check_account_balance
      params.merge!(balance: users.first.total_redeemable_points)
    else
      template = :account_balance_retailer_participant
      params.merge!(retailer_balance: get_account_balance_for(:retailer, users), participant_balance: get_account_balance_for(:participant, users))
    end
    return sms_body(template, params)
  end

  def check_account_balance_sms(mobile_number)
    user = User.where('mobile_number = ? and client_id = ?', params['From'].to_i, @client.id).first
    mobile = user.mobile_number.to_i
    users = @client.users.includes(:user_schemes).for_mobile_number(mobile).select('users.id, users.status')
    params = {client: @client.client_name}
    unless users.present?
      return sms_body(:invalid_account_sms_based, params)
    end
    if users.map(&:status).include?(User::Status::PENDING)
      return sms_body(:account_pending_sms_based, params)
    end
    if users.map(&:status).include?(User::Status::INACTIVE)
      return sms_body(:account_deregistered_sms_based, params)
    end
    if users.size == 1
      template = :check_account_balance
      params.merge!(balance: users.first.total_redeemable_points)
    else
      template = :account_balance_retailer_participant
      params.merge!(retailer_balance: get_account_balance_for(:retailer, users), participant_balance: get_account_balance_for(:participant, users))
    end
      users.first
      template = :check_account_balance
      params.merge!(balance: users.first.total_redeemable_points)

    return sms_body(template, params)
  end

  def clean_sms(body_text, slug = '', regex = '0-9A-Za-z')
    body_text.gsub!('7350003211', '')
    if body_text.present?
      clean_sms = (slug.present?) ? body_text.gsub(/#{slug}/i, '').strip : body_text.strip
      return clean_sms.gsub(/[^#{regex} ]/i,'').gsub(/\s+/, '')
    end
    ''
  end

  def get_account_balance_for(slug, users)
    balance = 0
    users.each do |user|
      if user.is_retailer? && slug == :retailer
        balance = user.total_redeemable_points
      elsif !user.is_retailer? && slug == :participant
        balance = user.total_redeemable_points
      end
    end
    balance
  end

  def get_product_code_label(unique_code)
    if unique_code.used?
      UniqueItemCode::State::ALREADY_USED
    elsif unique_code.expired?
      UniqueItemCode::State::EXPIRED
    elsif unique_code.inactive_pack?
      UniqueItemCode::State::INACTIVE_PRODUCT_PACK
    elsif unique_code.inactive_product?
      UniqueItemCode::State::INACTIVE_PRODUCT
    else
      "#{unique_code.reward_item_point.points} Points"
    end
  end

  def update_unique_codes(user_id, product_code_ids)
    puts "*****************update_unique_codes***************************"
    puts product_code_ids.inspect
    puts user_id
    UniqueItemCode.where(id: product_code_ids).update_all(user_id: user_id, used_at: Time.now)
  end

  def duplicate_linkage?(unique_code)
    check_code = DuplicateCodeLink.where(:code => unique_code.code).where('duplicate_code_links.used_count > 0')
    unless check_code.empty?
      return true
    else
      return false
    end
  end

  def update_duplicate_linkage_for_registered(user, unique_code)
    dup_code = DuplicateCodeLink.where(:code => unique_code.code).first
    actaul_update_flow(dup_code, user.id)
  end

  def update_duplicate_linkage_for_new_registration(user, product_codes)
    product_codes.each do |unique_item|
      dup_code = DuplicateCodeLink.where(:unique_item_code_id => unique_item).first
      actaul_update_flow(dup_code, user) unless dup_code.nil?
    end
  end

  def actaul_update_flow(dup_code, user_id)
    dup_code.used_count = dup_code.used_count - 1
    if dup_code.user_id_1.nil?
      user_info = check_client_and_user(user_id, @client)
      register_user_with_duplicate_code(user_id, @client) if user_info == true
      dup_code.update_attributes(:user_id_1 => user_id, :used_at_1 => Time.now, :used_count => dup_code.used_count)
      return true
    elsif dup_code.user_id_1 == user_id
      return false
    else
      dup_code.update_attributes(:user_id_2 => user_id, :used_at_2 => Time.now, :used_count => dup_code.used_count)
      return true
    end
  end

  def check_client_and_user(user_id, client)
    user = User.find(user_id)
    if client.client_name == "Hathi-Sidhee Bandhan"
      if user.status == "pending"
        return true
      else
        return false
      end
    else
      return false
    end 
  end

  def register_user_with_duplicate_code(user_id, client)
    user_details = User.find(user_id)
    update_user_status = user_details.update_attributes(:status => "active", :full_name => "Pending", :user_role_id => "451")
  end

  def refactor_code_labels(code_labels)
    code_labels_points = Array.new
    code_label_lables = Array.new
      code_labels.each do |code|
        if code.include?("Points")
          code_labels_points << 1
        else
          code_nummber = code.split(",").map { |s| s.to_i }.first
          code_label_lables << code_nummber
        end
      end
    return code_labels_points, code_label_lables
  end

  def check_duplicate_session(sms_details)
    puts "**************check_duplicate_session***************"
    puts sms_details.inspect
    check_duplicate_entry = StoreSmsSession.where(:sms_id => sms_details[:SmsSid], :from_user => sms_details[:From]).last
    if check_duplicate_entry.present?
      puts "+++++++++++++++++++check_duplicate_session++++++++++++++++++++"
      puts check_duplicate_entry.inspect
      return check_duplicate_entry.response
     else
    return false
    end
  end

  def store_first_sms_details(sms_details, template)
    puts "**************store_first_sms_details***************"
    puts sms_details.inspect
    StoreSmsSession.create(:sms_id => sms_details[:SmsSid], :from_user => sms_details[:From], :response => template)
  end

  def check_for_abbott_client(client)
    if client.id == 261
      return true
    else
      return false
    end
  end

  def check_for_abbott_client_logic(product_code, client, user)
    user = User.find(user.id)
    code_send_by_user = user.unique_item_codes.count
     if code_send_by_user == 1
      template = :abbott_first_message
     elsif code_send_by_user == 2
       template = :abbott_second_message
     elsif code_send_by_user == 3
       template = :abbott_third_message
     elsif code_send_by_user == 4
       template = :abbott_fourth_message
     elsif code_send_by_user
       template = :abbott_more_messages    
     end
    return template
  end

  def check_code_status_abbott(code_labels, client, product_codes)
    code_labels.each do |code|
      if code.include?("Already Used")
        return template = :abbott_used_code
      end
      if code.include?("Invalid")
        return template = :abbott_invalid_code
      end
    end
  end

end