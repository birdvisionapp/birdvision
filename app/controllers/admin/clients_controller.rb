class Admin::ClientsController < Admin::AdminController
  
  load_and_authorize_resource
  skip_authorize_resource :only => [:download_report, :list_user_roles, :list_telecom_regions]

  inherit_resources
  actions :all, :except => [:destroy, :show]

  before_filter :build_user_role, :only => [:new, :edit]

  def index
    @search = Client.accessible_by(current_ability).search(params[:q])
    @clients = @search.result.order("created_at desc").page(params[:page])
  end
  
  def new
    @client.build_client_customization unless @client.client_customization.present?
    @new_client = true
  end

  def create
    set_msp(@client)
    create!
  end

  def edit
    @client = Client.accessible_by(current_ability).includes(:user_roles => :sub_roles).find(params[:id])
    @client.build_client_customization unless @client.client_customization.present?
  end

  def download_report
    client = Client.accessible_by(current_ability).select_options.find(params[:client_id])
    respond_to do |format|
      format.csv {
        process_csv_report("#{client.client_name} report till #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model: 'Client', resource_id: client.id)
      }
    end
  end

  def list_user_roles
    user_roles = UserRole.includes(:client).main_roles.accessible_by(current_ability).select_options
    user_roles = user_roles.for_client(params[:client_id]) if params[:client_id].present?
    render :json => ancestry_options(user_roles, params[:client_id].present?).map{|v|{id: v[1], name: v[0]}}
  end

  def list_telecom_regions
    regions = RegionalManager.includes(:client, :admin_user).accessible_by(current_ability).select_options
    regions = regions.for_client(params[:client_id]) if params[:client_id].present?
    render :json => telecom_region_options(regions, params[:client_id].present?).map{|v|{id: v[1], name: v[0]}}
  end

  private

  def interpolation_options
    {:resource_description => @client.client_name}
  end

  def build_user_role
    @client.user_roles_main.build unless @client.user_roles_main.present?
  end
end