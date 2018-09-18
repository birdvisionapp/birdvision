module Admin::TargetedOfferManagersHelper
  
  def get_client_name(targeted_offer_config)
    targeted_offer_config.client.client_name
  end
  
  def get_msp_name(targeted_offer_config)
    if targeted_offer_config.msp.nil?
      return ""
    else
    return targeted_offer_config.msp.name
    end
  end
  
  def get_basis(template)
    if template.nil?
      ""
    else
      template.targeted_offer_type.offer_type_name
    end
  end
  
  def get_incentive(targeted_offer_config)
    if targeted_offer_config.targeted_offer_config_incentive.nil?
      ""
    else
      targeted_offer_config.targeted_offer_config_incentive.incentive  
    end
  end
  
  def to_client_schemes(to_conf)
    schemes = []
    to_schemes = to_conf.to_schemes 
    to_schemes.each do |scheme|
      schemes << Scheme.find(scheme.to_i).name  
    end
    schemes
  end
  
  def to_client_product(to_conf)
    products = []
    to_products = to_conf.to_products 
    to_products.each do |product|
      products << RewardItem.find(product.to_i).name  
    end
    products
  end
  
  def style_boolean_to_complete(value)
    if value == true
      return "Configuration complete"
    else
      return "Configuration pending"
    end
  end
  
  def find_incentive_info(to_id)
    Incentive.where(:targeted_offer_configs_id => to_id).first
  end
  
  def get_validity(to_config)
     to_config.targeted_offer_validity
  end

  def get_style_to_medium(config_id, type)
    sms = TargetedOfferConfig.find(config_id).sms_based
    email = TargetedOfferConfig.find(config_id).email_based
    
    unless sms.nil? && email.nil?
      if sms == true && type == "sms"
        return "active"
      elsif sms == false && type == "sms"
        return "inactive"
      elsif email == true  && type == "email"
        return "active"
      elsif email == false && type == "email"
        return "inactive"
      end
    else
      return "inactive"
    end
  end

  def get_rendered_incentive(template_id)
    incentive_name = Template.find(template_id).name 
    if incentive_name.include?("gift") || incentive_name.include?("Gift")
      return 'gift'
    elsif incentive_name.include?("points") || incentive_name.include?("Points")
      return 'points'
    end   
  end
  
  def get_all_product_status(config_id)
    TargetedOfferConfig.find(config_id).client.reward_items
  end
end
