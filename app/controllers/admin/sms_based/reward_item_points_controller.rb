class Admin::SmsBased::RewardItemPointsController < Admin::AdminController
  
  load_and_authorize_resource

  skip_authorize_resource :only => [:list_for_scheme, :link_codes]

  inherit_resources

  actions :all, :except => [:destroy]

  before_filter :load_user_roles, :load_telecom_regions, :only => :link_codes

  def index
    respond_to do |format|
      format.html {
        @search = RewardItemPoint.includes(:pack_tier_configs, :reward_item => [:client, :scheme]).accessible_by(current_ability).select('reward_item_points.id, reward_item_points.reward_item_id, reward_item_points.points, reward_item_points.pack_size, reward_item_points.metric, reward_item_points.status').search(params[:q])
        @reward_item_points = @search.result.page(params[:page])
      }
      format.csv { 
        process_csv_report("Reward Product Packs Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "RewardItemPoint.includes(:reward_item => [:client, :scheme]).accessible_by(current_ability).select('reward_item_points.id, reward_item_points.reward_item_id, reward_item_points.points, reward_item_points.pack_size, reward_item_points.metric, reward_item_points.status').search(#{params[:q]})")
      }
    end
  end

  def list_for_scheme
    is_template = params[:template].present? ? true : false
    products = RewardItemPoint.includes(:reward_item).accessible_by(current_ability).select_options
    products = products.where('reward_items.scheme_id = ?',  params[:scheme_id]) if params[:scheme_id].present?
    products = products.where('reward_items.client_id = ?',  params[:client_id]) if params[:client_id].present?
    render :json => products.map{|p|
      result = {id: p.id, name: p.product_detail, data_parent: p.reward_item.scheme_id}
      result.merge!(data_template: load_multi_tier_admin_sms_based_unique_item_codes_path(:source_id => p.id)) if is_template
      result
    }
  end

  def preview_conf
    @reward_item_point = RewardItemPoint.accessible_by(current_ability).find(params[:id])
    if @reward_item_point.update_attributes(params[:reward_item_point])

    end
    render layout: false
  end

  def link_codes
    params[:q] = {:unique_item_code_reward_item_point_id_eq => ""} unless params[:q]
    params[:q].merge!({:unique_item_code_reward_item_point_reward_item_client_id_eq => current_client.id}) if current_client.present?
    @search = ProductCodeLink.unused.includes(:linkable => :client).accessible_by(current_ability).where('product_code_links.linkable_type=?', 'User').select('COUNT(DISTINCT product_code_links.id) AS codes_count, product_code_links.linkable_id, product_code_links.linkable_type').group('product_code_links.linkable_id').search(params[:q])
    @product_code_links = @search.result.page(params[:page])
    if params[:q][:unique_item_code_reward_item_point_id_eq].present? && is_admin_user?
      @reward_item_point = RewardItemPoint.select([:id, :reward_item_id]).find(params[:q][:unique_item_code_reward_item_point_id_eq])
      reward_item = @reward_item_point.reward_item
      user_params = params[:q].slice!(:unique_item_code_reward_item_point_id_eq, :linkable_of_User_type_client_id_eq, :linkable_of_User_type_client_msp_id_eq, :linkable_of_User_type_user_schemes_scheme_id_eq)
      mappings = {
        "linkable_of_User_type_user_role_id_eq" => "user_role_id_eq",
        "linkable_of_User_type_telecom_circle_regional_managers_id_eq" => "telecom_circle_regional_managers_id_eq",
        "linkable_of_User_type_full_name_cont" => "full_name_cont",
        "linkable_of_User_type_username_cont" => "username_cont",
        "linkable_of_User_type_mobile_number_cont" => "mobile_number_cont"
      }
      user_params = Hash[user_params.map {|k, v| [mappings[k], v] }]
      user_params["client_id_eq"] = reward_item.client_id
      user_params.reject!{|key, val| val.blank? }
      user_model = User.includes(:client, :telecom_circle => :regional_managers).accessible_by(current_ability).sms_based
      user_model = user_model.region_scope if user_params['telecom_circle_regional_managers_id_eq'].present?
      @user_search = user_model.select('users.id, users.username, users.full_name, users.mobile_number, users.client_id, users.telecom_circle_id').search(user_params)
      @users = @user_search.result(:distinct => true).all
      @unused_single_tier_codes = @reward_item_point.unique_item_codes.unused.single_tier.no_links.count
    end
  end

  def store_links
    reward_item_point = RewardItemPoint.select(:id).find(params[:id])
    options = params[:user][:link_codes]
    reward_item_point.delay.link_codes(options.reject{|k, v| v=="" }) if options.present?
    flash[:notice] = "Product code linkages will be saved as per the configuration."
    redirect_to link_codes_admin_sms_based_reward_item_points_path
  end
  
  private
  
  def interpolation_options
    {:resource_description => @reward_item_point.product_detail}
  end

end


