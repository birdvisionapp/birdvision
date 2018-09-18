module Admin::Reports::ProductCodeLinkReport

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options, first)
      all.each do |code_link|
        csv << csv_row(code_link, options)
      end
    end
  end

  def csv_header(options, first_link)
    header = ["#{first_link.linkable.user_role.name} Name", "Product", "Code", "Points", "Expiry Date"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(code_link, options)
    row = [code_link.linkable.full_name,
      code_link.unique_item_code.reward_item_point.product_detail,
      code_link.unique_item_code.code,
      code_link.unique_item_code.reward_item_point.points,
      code_link.unique_item_code.expiry_date.strftime("%d-%b-%Y")]
    if options[:role] == 'super_admin'
      row.unshift(code_link.unique_item_code.reward_item_point.reward_item.client.client_name)
      row.unshift(code_link.unique_item_code.reward_item_point.reward_item.client.msp_name) if options[:is_super_admin]
    end
    row
  end

end

