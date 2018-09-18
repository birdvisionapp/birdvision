class TargettedOffer

  def self.targeted_offer
    Client.where(:is_targeted_offer_enabled => true).each do |client|
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Inside targeted offer"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  
     if client.targeted_offer_configs.count != 0
      client.targeted_offer_configs.each do |config|
      if config.status == "completed"
        if config.targeted_offer_validity.end_date < Date.today
            remove_users_from_toapplicable(config)
        end
      end
       if config.status == "completed" && config.to_disabled == "enabled"
        @user_id = user_filter_by_configration(client, config)
        if config.template.targeted_offer_type.offer_type_name == "Purchase Frequency" && config.targeted_offer_validity.start_date <= Date.today && config.targeted_offer_validity.end_date > Date.today
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          puts "Purchase Frequency"
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          @user = User.find(@user_id)
          purchase_frequency(@user, config)
          remove_users_from_toapplicable(config)
        end
        if config.template.targeted_offer_type.offer_type_name == "Major Life Event" && config.targeted_offer_validity.start_date <= Date.today && config.targeted_offer_validity.end_date > Date.today
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          puts "Major Life Event"
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
           @user = User.find(@user_id)
           major_life_event(@user, config)
           remove_users_from_toapplicable(config)
        end
        if config.template.targeted_offer_type.offer_type_name == "Relationship Matrix" && config.targeted_offer_validity.start_date <= Date.today && config.targeted_offer_validity.end_date > Date.today
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          puts "Relationship Matrix"
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
           @user = User.find(@user_id)
           relationship_matrix(@user, config)
           remove_users_from_toapplicable(config)
        end
        if config.template.targeted_offer_type.offer_type_name == "Seasonal Festival" && config.targeted_offer_validity.start_date <= Date.today && config.targeted_offer_validity.end_date > Date.today
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          puts "Seasonal Festival"
          puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          @user = User.find(@user_id)
          seasonal_festival(@user, config)
          remove_users_from_toapplicable(config)
        end
       end
      end
     end
    end
  end

  def self.purchase_frequency(users, config)
    puts "======================================"
    puts "purchase_frequency"
    puts "======================================"
    users.each do |user|
      #user_scheme_transaction = user.scheme_transactions.where('action = ?', 'credit').order('created_at DESC').limit(3)
       user_scheme_transaction = user.scheme_transactions.where('action = ?', 'credit').group('DATE(created_at)').order('created_at DESC').limit(3)
      if user_scheme_transaction.length >= 3
           diff = Time.diff(user_scheme_transaction[0].created_at, user_scheme_transaction[1].created_at,'%d')
           diff1 = Time.diff(user_scheme_transaction[1].created_at ,user_scheme_transaction[2].created_at,'%d')
           if diff[:diff].to_i != 0 && diff1[:diff].to_i != 0
              average = (diff[:diff].to_i + diff1[:diff].to_i)/2
           elsif diff[:diff].to_i != 0
              average = ( 1 + diff1[:diff].to_i)/2
           elsif diff1[:diff].to_i != 0
             average = ( diff[:diff].to_i + 1 )/2
           elsif diff[:diff].to_i == 0 && diff1[:diff].to_i == 0
             average = ( 1 + 1 )/2
           end
        if config.client_purchase_frequency <= average
           store_user_info(user, config)
        end
      end
    end
  end

  def self.relationship_matrix(users, config)
    puts "======================================"
    puts "relationship_matrix"
    puts "======================================"
    users.each do |user|
     user_performance = relationship_matrix_major_life_event(user, config)
     puts "6666666666666666666666666666666666666666666666666666666666666666666666666"
     puts user_performance.inspect
     puts "6666666666666666666666666666666666666666666666666666666666666666666666666"
     puts config.client_purchase_frequency.inspect
     puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
     if config.client_purchase_frequency <= user_performance
      puts "I am relationship_matrix"
           store_user_info(user, config)
     end
    end
  end

  def self.major_life_event(users, config)
    puts "======================================"
    puts "major_life_event"
    puts "======================================"
    users.each do |user|
    if user.dob.present?
      puts "11111111111111111111111111111111111111111111111111111111111111111111"
     user_performance = relationship_matrix_major_life_event(user, config)
     puts user_performance
     puts config.client_purchase_frequency
     if (config.client_purchase_frequency <= user_performance)
      if user.dob.strftime("%m-%d") == Date.today.strftime("%m-%d") #or user.anniversary.strftime("%m-%d") == Date.today.strftime("%m-%d"))
        puts "=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=================="
        puts user.inspect
        puts user.dob
        puts "=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=================="
        store_user_info(user, config)
      end
     elsif user.dob.strftime("%m-%d") == Date.today.strftime("%m-%d") #or user.anniversary.strftime("%m-%d") == Date.today.strftime("%m-%d"))
      UserNotifier.notify_birthday_to(user) if user.email.present?
      SmsMessage.new(:to_template_7, :to => user.mobile_number, :user_name => user.full_name, :client_name => user.client.client_name).delay.deliver if user.mobile_number.present?
     end
    end
   end
  end

  def self.relationship_matrix_major_life_event(user, config)
    puts "======================================"
    puts "relationship_matrix_major_life_event"
    puts "======================================"
     if config.performance_from.present? && config.performance_to.present?
      user_performance_check = user.scheme_transactions.where(:created_at => config.performance_from.beginning_of_day-1.day..config.performance_to.end_of_day+1.day).where('action = ?', 'credit').pluck(:points).sum
     else
      user_performance_check = user.scheme_transactions.where(:created_at => config.performance_from.beginning_of_day-1.day..Date.tomorrow.end_of_day).where('action = ?', 'credit').pluck(:points).sum
     end
     return user_performance_check
  end

  def self.seasonal_festival(users, config)
    puts "======================================"
    puts "seasonal_festival"
    puts "======================================"
    users.each do |user|
        store_user_info(user, config)
    end
  end

#store sorted users to ToApplicableUser table and send mail & sms
  def self.store_user_info(user, config)
    puts "--------------------------------------------------"
    puts "store_user_info"
    puts "--------------------------------------------------"
     @check_user_exist = ToApplicableUser.where('user_id = ?' , user.id)
      if @check_user_exist.empty?
        @check_user_exist = ToUtilizer.where('to_applicable_user_id = ? and targeted_offer_config_id = ?', user.id, config.id)
      end
      if @check_user_exist.empty?
        find_template_details = to_template_details(config)
      if config.email_based == true
        UserNotifier.notify_to(user, find_template_details) if user.email.present?
      end
      if config.sms_based == true
        send_sms(user, find_template_details) if user.mobile_number.present?
      end
        @applicable_user = ToApplicableUser.new(:targeted_offer_config_id => config.id, :user_id => user.id, :to_availed => "false")
        @applicable_user.save
      if config.template.targeted_offer_type.offer_type_name == "Relationship Matrix" || config.template.targeted_offer_type.offer_type_name == "Major Life Event"
         puts "-------------==============================0000000000000000000000000000000000000000"
         puts "-------------==============================0000000000000000000000000000000000000000"
         auto_update_to_transactions_info(@applicable_user, config)
      end
      end
  end

  def self.auto_update_to_transactions_info(applicable_user, config)
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    puts applicable_user.inspect
    puts config.inspect
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    incentive = Incentive.where(:targeted_offer_configs_id => applicable_user.targeted_offer_config_id).first
    targeted_offer_basis = applicable_user.targeted_offer_config.template.targeted_offer_type.id
    participant_id = User.find(applicable_user.user_id).participant_id
    applicable_user.update_attributes(:used_at => DateTime.now)
    transaction = ToTransaction.new(:user_id => applicable_user.user_id, :participant_id => participant_id, :targeted_offer_basis => targeted_offer_basis, :incentive_type => "Manual", :to_applicable_user_id => applicable_user.id, :targeted_offer_config_id => applicable_user.targeted_offer_config_id, :incentive_id => incentive.id, :unique_code => "Free Gift")
    transaction.save
  end

#Filter the users according to the configration
  def self.user_filter_by_configration(client, config)
    puts "************************************************************"
    puts "user_filter_by_configration"
    puts "************************************************************"
    @scheme = UserScheme.where(:scheme_id => config.to_schemes).collect(&:user_id).uniq
    @telecome_circle = User.where(:client_id => client.id, :telecom_circle_id => config.to_telephone_circles).collect(&:id).uniq
    @user_role = User.joins(:user_role).where(user_roles: {client_id: client.id}, user_roles: {id: config.to_user_roles}).collect(&:id).uniq
    #start_age = config.start_age.year.ago.to_date // commented but use later on when capture date
    #end_age = config.end_age.year.ago.to_date // commented but use later on when capture date
    #@age = User.where(:client_id => client.id).where("(dob >= ? AND dob <= ?) or (anniversary >= ? AND anniversary <= ?)", end_age, start_age, end_age, start_age) // commented but use later on when capture date
    @user_id = @scheme & @telecome_circle & @user_role #& @user_id
    return @user_id
  end

  def self.to_template_details(config)
    basis_name = config.template.targeted_offer_type.offer_type_name
    template_id = config.template.id
    to_end_date = config.targeted_offer_validity.end_date
    product_name = find_product_name(config.to_products)
    incentive = Incentive.where(:targeted_offer_configs_id => config.id)
    incentive_details = incentive.first.incentive_detail
    incentive_type = incentive.first.incentive_type
    festival_type = config.festival_type
    to_send = {:template_id => template_id, :incentive_type => incentive_type, :incentive_details => incentive_details, :end_date => to_end_date, :product_name => product_name, :basis_name => basis_name, :festival_type => festival_type }
    return to_send
  end
  
  def self.find_product_name(product_id)
    product = product_id
   if product != nil
     product_count = product.count
     @product_name = Array.new
    if product_count <= 3
       product.each do |pro|
         reward_item = RewardItem.find(pro)
         product_name = reward_item.name
         @product_name << product_name
       end
     return @product_name
    else
     @product_name << "Any Product"
     return @product_name
    end
   end
  end

#logic to remove users from ToApplicableUser start++++++++++++++++++++++++++++++++++++++++++++++++++
  def self.remove_users_from_toapplicable(config)
    puts "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
    puts "remove_users_from_toapplicable"
    puts "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
    @expire_users = Array.new
    if config.to_applicable_users.count > 0
     if config.targeted_offer_validity.end_date < Date.today
       @users_from_to = ToApplicableUser.where('targeted_offer_config_id = ?', config.id).each do |expire_user|
         used_at = lable_used_at(expire_user)
         @expire_users << "(#{expire_user.user_id}, #{expire_user.targeted_offer_config_id}, #{used_at})"
       end
       shift_user_from_toapplicable(@expire_users, @users_from_to)
     end
       incentive = Incentive.where(:targeted_offer_configs_id => config.id)
     if incentive.first.incentive_for == "first_action" && ToApplicableUser.where('targeted_offer_config_id = ? and used_at != ?', config.id, "nil").count != 0
        @users_from_to = ToApplicableUser.where('targeted_offer_config_id = ? and used_at != ?', config.id, "nil").each do |expire_user|
         used_at = lable_used_at(expire_user)
         @expire_users << "(#{expire_user.user_id}, #{expire_user.targeted_offer_config_id}, #{used_at})"
        end
         shift_user_from_toapplicable(@expire_users, @users_from_to)
     end
     if config.template.targeted_offer_type.offer_type_name == "Relationship Matrix" || config.template.targeted_offer_type.offer_type_name == "Major Life Event"
         @users_from_to = ToApplicableUser.where('targeted_offer_config_id = ? and used_at != ?', config.id, "nil").each do |expire_user|
          used_at = lable_used_at(expire_user)
          @expire_users << "(#{expire_user.user_id}, #{expire_user.targeted_offer_config_id}, #{used_at})"
         end
         shift_user_from_toapplicable(@expire_users, @users_from_to)
     end
    end
  end

  def self.lable_used_at(expire_user)
    if expire_user.used_at.nil?
       used_at = false
    else
       used_at = true
    end
      return used_at
  end

  def self.shift_user_from_toapplicable(expire_users, users_from_to)
    add_to_utilizer(expire_users)
    users_from_to.map(&:destroy)
  end

  def self.add_to_utilizer(expire_user)
      sql = "INSERT INTO `to_utilizers` (`to_applicable_user_id`, `targeted_offer_config_id`, `status`) VALUES #{expire_user.join(", ")}"
      ToUtilizer.connection.execute sql
  end

#logic to remove users from ToApplicableUser end++++++++++++++++++++++++++++++++++++++++++++++++++

#logic for SMS Template start +++++++++++++++++++++++++++++++++++++++++++++++++++
  def self.diff_product_name(product_name)
   if product_name != nil
    unless product_name.include? "Any Product"
      product = product_name.join(' or ')
      return product
    else
      return "any product"
    end
   end
  end

  def self.send_sms(user, template_details)
    puts "000000000000000000000000000000000000000000000000000000000"
    puts "send_sms"
    puts "000000000000000000000000000000000000000000000000000000000"
    client_name = user.client.client_name
    end_date = template_details[:end_date]
    product_name = diff_product_name(template_details[:product_name])
    incentive_details = template_details[:incentive_details]
    festival_type = template_details[:festival_type]

    if template_details[:incentive_type] == "percentage" && template_details[:basis_name] == "Purchase Frequency"
      SmsMessage.new(:to_template_1, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present?
    elsif template_details[:incentive_type] != "percentage" && template_details[:basis_name] == "Purchase Frequency"
      SmsMessage.new(:to_template_2, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present? 
    elsif template_details[:basis_name] == "Relationship Matrix"
      SmsMessage.new(:to_template_3, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present?
    elsif template_details[:basis_name] == "Major Life Event"
      SmsMessage.new(:to_template_4, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present?
    elsif template_details[:incentive_type] == "percentage" && template_details[:basis_name] == "Seasonal Festival"
      SmsMessage.new(:to_template_5, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present?
    elsif template_details[:incentive_type] != "percentage" && template_details[:basis_name] == "Seasonal Festival"
      SmsMessage.new(:to_template_6, :to => user.mobile_number, :user_name => user.full_name, :end_date => end_date, :product_name => product_name, :incentive_details => incentive_details, :client_name => client_name, :festival_type => festival_type).delay.deliver if user.mobile_number.present?
    end
  end
#logic for SMS Template end +++++++++++++++++++++++++++++++++++++++++++++++++++

end