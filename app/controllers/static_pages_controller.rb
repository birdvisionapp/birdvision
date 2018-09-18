class StaticPagesController < ApplicationController
  before_filter :hide_header_components
  before_filter :set_contact_details, :only => [:contact_us, :contact_request]

  def hide_header_components
    @hide_search = true
  end

  def contact_request
    @message = "Please fill all fields."
    @type = :alert
    if params["contact_name"].present? && params["contact_message"].present? && params["contact_email"].present?
      ContactUsMailer.delay.send_mail(@to_email, {:name => params["contact_name"], :email => params["contact_email"], :message => params["contact_message"]})
      @message = "Your message has been sent to our Team."
      @type = :notice
    end
    render :contact_us, @type => @message
  end

  private

  def set_contact_details
    @to_email = CONTACT_US_RECIPIENT
    @phone_number = '020-6606 2774'
    @company = APP_TITLE
    @cc_email = 'customercare@birdvision.in'
    client = Client.where(code: params[:ccode]).first
    unless client
      if client_for_admin_user
        client = client_for_admin_user
      else
        client = client_for_host
      end
    end
    if client.present? && client.msp_id.present?
      @to_email = client.cu_email
      @company = client.msp.name
      @phone_number = client.cu_phone_number
      @cc_email = client.cu_cc_email
    end
  end

end
