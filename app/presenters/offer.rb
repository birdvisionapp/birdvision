class Offer

  def initialize(admin_user, client)
    @current_ability = Ability.new(admin_user)
    @client_info = client
  end
  
  def schemes_list
    @schemes = RewardItem.joins(:client).where(:clients => {:id => client_info}).collect(&:scheme_id).uniq
    # RewardItem.joins(:client).where(:clients => {:id => @client}).collect(&:scheme_id).uniq
  end
  
  def client_catlog_items
    client_catalog_id = Client.find(client_info).client_catalog_id 
    client_items = ClientItem.select(:slug).where("client_catalog_id = ?" , client_catalog_id)
  end
  
  def to_types
    TargetedOfferType.all
  end
  
  def get_client_templates(tot_id)
    templates = Array.new
    client_templates = Client.find(client_info).templates
    client_templates.each do |template|
      if template.targeted_offer_type_id == tot_id
       templates << template 
      end
    end
    return templates
  end
  
  def get_schemes
    @schemes = RewardItem.joins(:client).where(:clients => {:id => client_info}).collect(&:scheme_id).uniq
    @scheme_name = Scheme.find(@schemes)
    # return @scheme_name
  end
  
  def get_client_schemes
    Scheme.where(:client_id => client_info)
  end

  def get_user_roles(config_id)
    to_user_role = TargetedOfferConfig.find(config_id).to_user_roles
    user_category_count = Client.find(client_info).user_roles.count
    if to_user_role != '{}'
      if to_user_role.length < user_category_count
        user_role = to_user_role
        user_name = Array.new
        user_role.each do |roles|
          user_name << UserRole.find(roles).name
        end
      return user_name
      else
        return ["All User's Catageory"]
      end
    else
      return ["No User's Catageory Selected"]
    end
  end
  
  def telecom_circle_info(telecom_circles)
    TelecomCircle.find_all_by_id(telecom_circles)
  end 
  
  def get_noproduct_scheme(tot_id)
    TargetedOfferType.find(tot_id)
  end
private

  def current_ability
    @current_ability
  end
  
  def client_info
    @client_info
  end 
end