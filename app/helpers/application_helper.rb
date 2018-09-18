module ApplicationHelper
  def admin_points_summary_path(options)
    admin_scheme_transactions_path(:q => options)
  end

  def points_summary_link(options, is_button = false)
    link_to 'Points Statement', admin_points_summary_path(options), :class=> (is_button) ? 'btn btn-info' : ''
  end

  def styling_boolean_label(slug)
    (slug) ? content_tag(:span, 'Yes', :class => 'lb-green') : content_tag(:span, 'No', :class => 'lb-red')
  end

  def styling_status_label(status, count = '')
    content_tag(:span, "#{status.titleize} #{"- #{count}" if count != ''}", :class => "badge badge-#{get_badge_type(status.downcase)}")
  end

  def get_badge_type(status)
    case(status)
    when 'active', 'confirmed'
      'success'
    when 'inactive', 'processing'
      'important'
    when 'pending'
      'warning'
    end
  end

  def report_generated_by(report)
    return nil unless is_admin_user?
    "By #{report.admin_user.role.titleize}: #{report.admin_user.username}" if report.admin_user.present?
  end

  def get_basis(t)
    TargetedOfferType.find(t.targeted_offer_type).offer_type_name
  end

  def check_scheme_name(scheme)
    Scheme.find(scheme).name
  end
  
  def client_user_roles(client_id)
    UserRole.where(:client_id => client_id)
  end

  def check_product_count(product_name)
    unless product_name.include? "Any Product"
      product = product_name.join(' or ')
      return product
    else
      return "any product"
    end
  end
  
  def get_bg_image_for_client(resource)
    url = request.host
    current_client = Client.find(:all, :conditions=>['domain_name = ?', "#{url}"]).first
    if current_client.present?
      @image_url = current_client.client_customization.image.url unless current_client.client_customization.nil?
      return @image_url
    end
  end
  
  def lnt_user(user)
    # return (request.host == "mydomain.live.com")
    return (request.host == ("dsp.bvcrewards.com") || (request.host == "qa3.bvcrewards.com") || (request.host == "mydomain.live.com"))
  end
  
 def bandhan_user(user)
    unless user.nil?
      if user.class.name == "AdminUser"
        if user.representative.present?
          return true if user.representative.client_id == 191
        elsif user.client_manager.present?
          return true if user.client_manager.client_id == 191
        elsif user.regional_manager.present?
          return true if user.regional_manager.client_id == 191
        end
      elsif user.class.name != "AdminUser"
        return true if user.client_id.present? && user.client_id == 191
      else
        return false
      end
    end
    return false
 end
 
 def is_signup_allowed(url)
    flag = true
    current_client = Client.find(:all, :conditions=>['domain_name = ?', "#{request.host}"]).first
    if !current_client.nil?
      flag = !current_client.client_customization.sign_up_enabled? if current_client.client_customization.present?
    end
    flag = true if url.include?('/admin')
    return flag
  end
  
  def is_gvi(current_admin_user)
    current_admin_user.msp_id == 21 && is_msp_admin?
  end

end
