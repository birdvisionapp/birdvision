class Admin::TargetedOfferManagersController < ApplicationController
  
  layout "admin"

  before_filter :authenticate_admin_user!
  
  def show
    @targeted_offer_config = TargetedOfferConfig.find(params[:id])
    @offer = Offer.new(current_admin_user ,@targeted_offer_config.client.id)
  end

  def destroy
    @toc = TargetedOfferConfig.find(params[:id])
    @toc.update_attributes(:to_disabled => "disabled")
    flash[:notice] = "Targeted Offer deleted successfully"
    redirect_to targeted_offer_list_admin_targeted_offer_managers_path
  end
  
  def to_configured_clients_listing
    if is_super_admin?
      @targeted_offer_configs = TargetedOfferConfig.where(:to_disabled => 'enabled')  
    elsif is_msp_admin?
      msps = current_admin_user.msp_id
      client_ids = Client.where("msp_id = ? and is_targeted_offer_enabled = ?", msps, true).pluck(:id)
      @targeted_offer_configs = TargetedOfferConfig.where(:client_id => client_ids).where(:to_disabled => 'enabled')
    elsif current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
      @targeted_offer_configs = TargetedOfferConfig.where('client_id =? AND to_disabled =?', clients, 'enabled')
    end
  end
  
  def to_config
     if is_super_admin?
      @msps = Msp.where("is_targeted_offer_enabled = ?", true)
      @clients = Client.where("is_targeted_offer_enabled = ?", true)
    elsif is_msp_admin?
      msps = current_admin_user.msp_id
      @msps = Msp.find_all_by_id(msps)
      @clients = Client.where("msp_id =? and is_targeted_offer_enabled = ?", msps, true)
    end
    respond_to do |format|
      format.js
    end
  end
  
  def select_client
    msp_id = params[:msp_id]
    msp_id = msp_id.to_i
    if msp_id > 0 
      @clients = Client.where("msp_id = ? and is_targeted_offer_enabled = ?", msp_id , true).select("id, client_name").to_json
    else
      @clients = Client.where("is_targeted_offer_enabled = ?" , true).to_json
    end
    respond_to do |format|
      format.json { render json: @clients}
    end
  end
  
  def product
    schemes = params[:schemes]
    client_id = params[:client_id]
    @reward_scheme = RewardItem.where(:scheme_id => schemes)
    @reward_client = RewardItem.where(:client_id => client_id)
    @products = (@reward_scheme & @reward_client)
    respond_to do |format|
      format.js
    end
  end

   def offer_manager
    if current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
      @client_id = clients
    elsif params[:client][:client_id_dropdown] == ""
      flash[:alert] = "Please select the client"
      redirect_to targeted_offer_list_admin_targeted_offer_managers_path
    else
      @client_id = params[:client][:client_id_dropdown]
    end
  end
    
  def render_required_templates
    @client_id = params[:client_id]
    @name = params[:name].parameterize.underscore
    @offer = Offer.new(current_admin_user, @client_id)
    @tot = TargetedOfferType.where("offer_type_name = ? " , params[:name]).first  
  end
  
  def create_and_store_offer
    client_id = params[:offer_manager][:client_id]
    unless params[:schemes].nil?
      to_config = store_config(client_id, params)
      store_incentive_info(to_config, params[:offer_manager])
      redirect_to campaingn_manager_admin_targeted_offer_managers_path(:client_id => client_id, :to_conf => to_config.id)
     else
       flash[:alert] = "There is no product under the schemes."
       redirect_to targeted_offer_list_admin_targeted_offer_managers_path
     end
  end
  
  def store_offer
    @targeted_offer_config = TargetedOfferConfig.find(params[:offer_manager][:config_id])
    client_id = params[:offer_manager][:client_id]
    store_incentive_info(@targeted_offer_config, params[:offer_manager])
    @targeted_offer_config.update_attributes(:client_purchase_frequency => params[:offer_manager][:client_purchase_frequency],
                                             :to_schemes => params[:schemes],
                                             :to_products => params[:select_product],
                                             :festival_type => params[:offer_manager][:festival_type])
    store_performnce_dates(@targeted_offer_config , params)
    if params[:offer_manager].include?("edit")
      @targeted_offer_config.update_attributes(:template_id => params[:offer_manager][:template])
      redirect_to campaingn_manager_edit_admin_targeted_offer_managers_path(:client_id => client_id, :to_conf => @targeted_offer_config)
    end
  end
   
  def campaingn_manager
    @targeted_offer_config = TargetedOfferConfig.find(params[:to_conf])
  end
  
  def store_campaingn
    campaingn_params = params[:campaingn_manager]
    client_id = campaingn_params[:client_id]
    @targeted_offer_config = TargetedOfferConfig.find(campaingn_params[:config_id])
    to_validity = store_validity(@targeted_offer_config , campaingn_params[:start_date], campaingn_params[:end_date])
    if campaingn_params[:age_range] == "custom-age-range"
      start_age = campaingn_params[:age_from].to_i
      end_age = campaingn_params[:age_to].to_i
    else
      start_age = 1
      end_age = 100
    end
    telecom_circles = params[:telecom_circle_select]
    @targeted_offer_config.update_attributes(:start_age => start_age,
                                            :end_age => end_age,
                                            :targeted_offer_validity_id => to_validity.id,
                                            :to_user_roles => params[:selective_category_ids],
                                            :to_telephone_circles => telecom_circles)
    if params[:campaingn_manager].include?("edit") 
      redirect_to  communication_manager_edit_admin_targeted_offer_managers_path(:client_id => client_id, :to_conf => @targeted_offer_config)
    else
      redirect_to communication_manager_admin_targeted_offer_managers_path(:client_id => client_id, :to_conf => @targeted_offer_config)
    end
  end
  
  def communication_manager
    @targeted_offer_config = TargetedOfferConfig.find(params[:to_conf])
  end
  
  def store_communication
    @targeted_offer_config = TargetedOfferConfig.find_or_initialize_by_id(params[:communication][:config_id])
    client_id = TargetedOfferConfig.find_or_initialize_by_id(params[:communication][:client_id])
    if params[:communication][:sms_based] == "0" && params[:communication][:email_based] == "0"
      flash[:alert] = "Please select communication medium."
      redirect_to communication_manager_admin_targeted_offer_managers_path(:client_id => client_id, :to_conf => @targeted_offer_config)
    else
      @targeted_offer_config = TargetedOfferConfig.find(params[:communication][:config_id])
      @targeted_offer_config.update_attributes(:sms_based => params[:communication][:sms_based] , :email_based => params[:communication][:email_based] , :status => "completed" )
      @targeted_offer_config.save
      flash[:success] = "Targeted offer successfully configured"
      redirect_to targeted_offer_list_admin_targeted_offer_managers_path
    end
  end
  
  def offer_manager_edit
    @targeted_offer_config = TargetedOfferConfig.find(params[:id])
  end
  
  def campaingn_manager_edit
    @targeted_offer_config = TargetedOfferConfig.find(params[:to_conf])
  end
  
  def communication_manager_edit
    @targeted_offer_config = TargetedOfferConfig.find(params[:to_conf])
  end
  
private

  def clients
    @clients ||= Client.accessible_by(current_ability).live_client.pluck(:id).first
  end

  def store_incentive_info(to_conf, offer_info)
    incentive = Incentive.find_or_initialize_by_targeted_offer_configs_id(to_conf.id)
    incentive.incentive_for = offer_info[:first_action]
    if offer_info[:incentive_type] == "percentage"
      incentive.incentive_type = offer_info[:incentive_type]
      incentive.incentive_detail = offer_info[:incentive_percentage]
    else
      if offer_info[:incentive_type] == "gift" || offer_info[:incentive_type].nil? 
        if offer_info[:incentive_type_gift] == "client-gift"
          incentive.incentive_type = offer_info[:incentive_type_gift]
          incentive.incentive_detail = offer_info[:gift_name]
        else
          incentive.incentive_type = offer_info[:incentive_type_gift]
          incentive.incentive_detail = offer_info[:gift_catlog_id]
        end
      end
    end
    incentive.save
    return incentive
  end
  
  def store_config(client_id , config_info)
    client = Client.find(client_id)
    to_config = TargetedOfferConfig.new(:client_purchase_frequency => config_info[:offer_manager][:client_purchase_frequency],
                                        :client_id => client_id , 
                                        :to_schemes => config_info[:schemes],
                                        :to_products => config_info[:select_product],
                                        :template_id => config_info[:select_template],
                                        :msp_id => client.msp_id,
                                        :festival_type => config_info[:offer_manager][:festival_type])
    to_config.save
    store_performnce_dates(to_config , params)
    return to_config
  end
  
  def store_validity(config , start_date , end_date)
    to_validity = TargetedOfferValidity.find_or_initialize_by_targeted_offer_config_id(config.id)
    to_validity.start_date = start_date
    to_validity.end_date = end_date
    to_validity.save!
    return to_validity
  end

  def store_performnce_dates(to_config, params)
    if params[:offer_manager][:performace_count] == "to_start"
      to_config.update_attributes(:performance_from => to_config.created_at, :performance_to => nil)
    elsif params[:offer_manager][:performace_count] == "scheme_start"
      unless to_config.to_schemes.empty?
        to_config.update_attributes(:performance_from => Scheme.find(to_config.to_schemes.first.to_i).start_date, :performance_to => nil)
      end
    elsif params[:offer_manager][:performace_count] == "custom_date"
      performance_from = Date.parse(params[:offer_manager][:performance_from]).strftime("%d-%m-%Y")
      performance_to =  Date.parse(params[:offer_manager][:performance_to]).strftime("%d-%m-%Y")
      
      to_config.update_attributes(:performance_from => performance_from,
                                  :performance_to => performance_to)
    end
    to_config.save
  end
  
  def is_super_admin?
    is_admin_user? && !current_admin_user.msp_id.present?
  end

  def is_msp_admin?
    is_admin_user? && current_admin_user.msp_id.present?
  end

  def is_admin_user?
    current_admin_user.super_admin?
  end
end