module Admin::Reports::RewardProductReport

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |product|
        csv << csv_row(product, options)
      end
    end
  end

  def csv_header(options)
    header = ["Scheme", "Product Name", "Pack Size - Points - Codes", "Status", "Created On"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(product, options)
    row = [product.scheme.name,
      product.name,
      product.pack_details,
      product.status.titleize,
      product.created_at.strftime("%d-%b-%Y")]
    if options[:role] == 'super_admin'
      row.unshift(product.client.client_name)
      row.unshift(product.client.msp_name) if options[:is_super_admin]
    end
    row
  end

end

