module Admin::Reports::RewardProductPackReport

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |product_pack|
        csv << csv_row(product_pack, options)
      end
    end
  end

  def csv_header(options)
    header = ["Scheme", "Product Name", "Pack Size", "Points", "Status", "Last Created At", "Product Codes"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(product_pack, options)
    row = [product_pack.reward_item.scheme.name,
      product_pack.reward_item.name,
      product_pack.pack_size_metric,
      product_pack.points,
      product_pack.status.titleize,
      (product_pack.unique_item_codes.present?) ? product_pack.unique_item_codes.last.created_at.strftime("%a, %b %e, %Y at %H:%M %p") : nil,
      product_pack.product_code_detail.join(", ")
    ]
    if options[:role] == 'super_admin'
      row.unshift(product_pack.reward_item.client.client_name)
      row.unshift(product_pack.reward_item.client.msp_name) if options[:is_super_admin]
    end
    row
  end

end

