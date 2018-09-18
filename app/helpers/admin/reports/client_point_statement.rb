module Admin::Reports::ClientPointStatement

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |transaction|
        csv << csv_row(transaction, options)
      end
    end
  end

  def csv_header(options)
    header = ["Date", "Credit", "Debit", "Balance"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(transaction, options)
    row = [transaction.trans_date.strftime("%d-%b-%Y"),
      transaction.credit,
      transaction.debit,
      transaction.balance
    ]
    if options[:role] == 'super_admin'
      row.unshift(transaction.client.client_name)
      row.unshift(transaction.client.msp_name) if options[:is_super_admin]
    end
    row
  end
  
end
