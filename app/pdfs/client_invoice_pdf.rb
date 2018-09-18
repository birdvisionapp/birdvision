class ClientInvoicePdf < Prawn::Document

  def initialize(invoice, view)
    super()
    @invoice = invoice
    @view = view

    define_grid(:columns => 5, :rows => 10, :gutter => 10)
   
    grid([0,0], [1,1]).bounding_box do
      text  @invoice.invoice_label.upcase, :size => 18
      text "#{@invoice.invoice_label} No: #{@invoice.invoice_number}", :align => :left
      text "Date: #{@invoice.invoice_date.strftime('%d-%m-%Y')}", :align => :left
      move_down 10

      text @invoice.client.client_name
      move_down 3
      text @invoice.client.address, :size => 9.5
    end

    grid([0,4.2], [1,3]).bounding_box do
      logo_path =  "#{Rails.root}/app/assets/images/bvc-logo.png"

      image logo_path, :width => 200, :height => 60, :position => :left

      move_down 10
      text App::Config.settings[:company_name], :align => :left
      move_down 3
      text App::Config.settings[:company_address], :align => :left, :size => 9.5
    end
    move_down 10
    text @invoice.description, :style => :bold_italic
    stroke_horizontal_rule

    move_down 30
    send("#{@invoice.invoice_type}_data")
    move_down 20
    invoice_details
    move_down 25
    text "Please make payment (Netbanking/Cheque/DD) in favour of \"#{App::Config.settings[:company_name]}\""
    move_down 8
    text "Service Tax No. #{App::Config.settings[:service_tax_number]}"
    move_down 8
    text "Service Tax Category: #{App::Config.settings[:service_tax_category]}"
    move_down 8
    text "PAN No. #{App::Config.settings[:pan_number]}"

    move_down 30
    text "* This is an electronically generated #{@invoice.invoice_label.downcase}. No signature required.", :style => :italic, :size => 10

    bounding_box([bounds.right - 50, bounds.bottom], :width => 60, :height => 20) do
      pagecount = page_count
      text "Page #{pagecount}"
    end
  end

  private

  def monthly_retainer_data
    charges_breakup = [
      ["Sr. No.", "Description", "Qty", "Unit (INR)", "Total (INR)"],
      [content('1.', :center), @invoice.description, content('-', :center), content('-', :center), @view.bvc_currency(@invoice.fixed_amount)]
    ]
    charges_breakup << [content('2.', :center), 'Participant Charges', content(@invoice.users_count, :center), content(@invoice.participant_rate, :center), @view.bvc_currency(@invoice.participant_basis)] if @invoice.participant_basis
    charges_breakup = charges_breakup + [
      [content("Sub Total (INR)", :right, 4), @view.bvc_currency(@invoice.mr_total_amount)],
      [content("Service Tax @ #{SERVICE_TAX}% (INR)", :right, 4), @view.bvc_currency(@invoice.mr_tax)],
      [content("Grand Total (INR)", :right, 4), @view.bvc_currency(@invoice.amount)],
    ]
    table charges_breakup, :header => true, :width => 540, :column_widths => { 4 => 100 } do
      row(0).font_style = :bold
      row(0).align = :center
    end
  end

  def content text, align = :left, colspan = 0, font_style = :normal
    {:content => text.to_s, :align => align, :font_style => font_style, :colspan => colspan}
  end
  
  def points_upload_data
    description_value = [
      ["Description", "Total Value (INR)"],
      [@invoice.breakup[0][0], @invoice.points_to_rupees]
    ]
    table description_value, :header => true, :column_widths => { 0 => 347, 1 => 193} do
      row(0).font_style = :bold
    end
    move_down 20
    charges_breakup = [
      ["Points Uploading Charges (INR) (@ #{@invoice.puc_rate}% of Total Value)", @invoice.points_rate],
      [@invoice.breakup[4][0], @invoice.pu_tax],
      [{:content => "Total (INR)", :align => :right}, @invoice.pu_charge_with_tax]
    ]
    table charges_breakup, :header => true, :column_widths => { 0 => 347, 1 => 193}
  end

  def invoice_details
    invoice_details = [
      [{:content => "Amount (INR)", :font_style => :bold}, @view.bvc_currency(@invoice.amount)],
      [{:content => "Amount in Words (INR)", :font_style => :bold}, "#{@invoice.amount.rupees} Only"]
    ]
    table invoice_details, :header => true, :column_widths => { 0 => 150, 1 => 390}
  end

end