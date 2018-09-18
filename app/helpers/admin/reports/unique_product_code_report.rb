module Admin::Reports::UniqueProductCodeReport

  def to_csv options = {}
    used ||= options[:dync_param]
    CSV.generate do |csv|
      csv << send("#{used}csv_header", options)
      find_each(:batch_size => 6000) do |unique_code|
        csv << send("#{used}csv_row", unique_code, options)
      end
    end
  end
  
  def csv_header(options)
    header = ["Scheme", "Product", "Code", "Points", "Expiry Date", "Created On", "Tier", "CodesPack Number"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(unique_code, options)
    row = [unique_code.reward_item_point.reward_item.scheme.name,
      unique_code.reward_item_point.product_detail,
      unique_code.code,
      unique_code.reward_item_point.points,
      unique_code.expiry_date.strftime("%d-%b-%Y"),
      unique_code.created_at.strftime("%d-%b-%Y"),
      unique_code.tier_name,
      unique_code.pack_number]
    if options[:role] == 'super_admin'
      row.unshift(unique_code.reward_item_point.reward_item.client.client_name)
      row.unshift(unique_code.reward_item_point.reward_item.client.msp_name) if options[:is_super_admin]
    end
    row
  end

  def used_csv_header(options)
    header = ["Scheme", "Product", "Code", "Points", "Full Name", "Username", "Mobile Number", "Used At", "Category", "Participant Linked"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def used_csv_row(unique_code, options)
    row = [unique_code.reward_item_point.reward_item.scheme.name,
      unique_code.reward_item_point.product_detail,
      unique_code.code,
      unique_code.reward_item_point.points,
      unique_code.user.full_name,
      unique_code.user.username,
      unique_code.user.mobile_number,
      unique_code.used_at.strftime("%a, %b %e, %Y at %H:%M %p"),
      unique_code.user.role_display,
      unique_code.link_details]
    if options[:role] == 'super_admin'
      row.unshift(unique_code.reward_item_point.reward_item.client.client_name)
      row.unshift(unique_code.reward_item_point.reward_item.client.msp_name) if options[:is_super_admin]
    end
    row
  end


  def to_pdf options = {}
    templates = LanguageTemplate.active.where(id: options[:languages]).select([:name, :template])
    labels = []
    all.each do |product_code|
      label_text = templates.map{|template| {:font => template.name, :text => Liquid::Template.parse(template.template[:coupon_code]).render('code' => product_code.code, 'points' => product_code.reward_item_point.points, 'sms_number' => product_code.reward_item_point.reward_item.client.sms_number)} }
      labels << ProductCodeLabel.new(label_text, (product_code.pack_tier_config.present?) ? product_code.pack_tier_config.user_role.color_hex : '')
    end
    Prawn::Labels.render(labels, :type => "Avery5160") do |pdf, label|
      label.render(pdf)
    end
  end

  def registrations_to_csv
    CSV.generate do |csv|
      csv << ["Mobile Number", "Name", "Status", "Date of Message", "Distributor"]
      find_each do |used_code|
        csv << [used_code.user.mobile_number, used_code.user.full_name, used_code.user.sms_status, used_code.used_at.strftime("%d-%b-%Y"), used_code.product_code_link.linkable.full_name]
      end
    end
  end

  def performance_to_csv
    CSV.generate do |csv|
      csv << ["#{find(:first).user.user_role.name} Name", "Mobile Number", "Points", "Purchase Volume"]
      all.group_by{|u| u.user }.each do |user, used_codes|
        sales_volume = SalesVolume.new(used_codes)
        csv << [user.full_name, user.mobile_number, sales_volume.total_points_earned, sales_volume.total_sales_volume]
      end
    end
  end

end