class AshokCsvParse

	def self.check_user_points(pur_date, so_code, sg_code, user_code, dealer_hir, part_number, quantity)
	  begin
  		pur_date = Date.parse(pur_date)
  		check_for_user = User.where(:participant_id => user_code, :client_id => ENV['AL_CLIENT_ID'].to_i).first
  		check_linkage = AlChannelLinkage.where(:retailer_code => user_code, :dealer_code => sg_code).first
  		if !check_linkage.nil?
    		calculated_points, reward_item_point, points = calulate_points(sg_code, user_code, part_number, quantity)
    		save_user_total(pur_date, so_code, sg_code, check_for_user, user_code, dealer_hir, part_number, points, quantity, calculated_points, reward_item_point)
    		User.update_user_scheme(check_for_user, @user_transaction)
      else
        user_id = check_for_user.id rescue nil
        AlTransactionIssue.create(user_id: user_id, sap_code: user_code, purchase_date: pur_date, sales_office_code: so_code, sales_group_code: sg_code, 
              dealer_hierarchy: dealer_hir, quantity: quantity, part_number: part_number, error: "Unauthorized Purchase")
	    end
	    rescue Exception => e
	   	  user_id = check_for_user.id rescue nil
	   	  find_error_message = error_message(e.message) rescue nil
        AlTransactionIssue.create(user_id: user_id, sap_code: user_code, purchase_date: pur_date, sales_office_code: so_code, sales_group_code: sg_code, 
            	dealer_hierarchy: dealer_hir, quantity: quantity, part_number: part_number, error: find_error_message) rescue []
            	puts "Error message: #{e.message}"
    end
	end

	def self.calulate_points(sg_code, user_code, part_number, quantity)
		reward_item_point = RewardItemPoint.joins(:reward_item).where(reward_items: {al_part_no: part_number}).last
		unless quantity.nil?
			total_points = reward_item_point.points * quantity.to_i
		else
			total_points = reward_item_point.points * 0
		end
		if reward_item_point.present?
			return total_points, reward_item_point, reward_item_point.points 
		else
			return nil, nil, nil
		end
	end

	def self.save_user_total(pur_date, so_code, sg_code, check_for_user, user_code, dealer_hir, part_number, points, quantity, calculated_points, reward_item_point)
		@user_transaction = AlTransaction.create(user_id: check_for_user.id, sap_code: user_code, purchase_date: pur_date, 
		sales_office_code: so_code, sales_group_code: sg_code, dealer_hierarchy: dealer_hir,
	 part_number: part_number, part_points: points, quantity: quantity, total_points: calculated_points, reward_item_point_id: reward_item_point.id)
	end

	def self.error_message(message)
		if message == "Called id for nil, which would mistakenly be 4 -- if you really wanted the id of nil, use object_id"
			return "User is not present"
		elsif message == "undefined method `points' for nil:NilClass"
			return "Product is not present"
		else
			return message
		end	
	end

end