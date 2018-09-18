class OfferManagers

  def initialize(config_id)
    @targeted_offer_config = TargetedOfferConfig.find(config_id)
  end

  #For Configuration
  
  def get_client_user_roles
    Client.find(get_client).user_roles
  end
  
  def get_client_templates
    @targeted_offer_config.client.templates
  end
  
  def get_schemes
    @schemes = RewardItem.joins(:client).where(:clients => {:id => @targeted_offer_config.client.id}).collect(&:scheme_id).uniq
  end
  
  def get_client_catlog
    client_catalog_id = Client.find(@targeted_offer_config.client.id).client_catalog_id 
    return ClientItem.select(:slug).where("client_catalog_id = ?" , client_catalog_id)    
  end
  
  def get_telecom_circles
    TelecomCircle.all
  end
  
  
  def get_selected_telecom_circle
    #TelecomCircle.find(@targeted_offer_config.to_telephone_circles.first)
    TelecomCircle.where(:id => @targeted_offer_config.to_telephone_circles.first).select([:id, :description]).first
  end

  def get_client_products
    Client.find(@targeted_offer_config.client.id).reward_items
  end
  
  #For Editing Configuration
  def get_offer_schemes
    @targeted_offer_config.to_schemes.map(&:to_i)
  end
  
  def offer_products
    @targeted_offer_config.to_products.map(&:to_i)
  end
  
  def get_template_acc_basis(tot_id)
    TargetedOfferType.find(tot_id).templates
  end
  
  def get_client_user_roles
    @targeted_offer_config.client.user_roles
  end
  
  def get_offer_user_roles
    if @targeted_offer_config.to_user_roles == "{}"
      return nil
    else
      return @targeted_offer_config.to_user_roles.map(&:to_i)
    end 
  end
  
  def get_validity
    @targeted_offer_config.targeted_offer_validity
  end
  
  private
  def get_client
    @client = @targeted_offer_config.client.id
  end
end