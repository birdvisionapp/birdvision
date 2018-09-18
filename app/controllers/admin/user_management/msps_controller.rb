class Admin::UserManagement::MspsController < Admin::AdminController

  inherit_resources
  load_and_authorize_resource
  skip_authorize_resource :only => [:list_options]
  actions :all, :except => [:destroy]
  
  def index
    @search = Msp.search(params[:q])
    @msps = @search.result.page(params[:page])
  end

  def create
    create! { admin_user_management_msps_path }
  end

  def list_options
    slug = params[:slug].split(":")
    options = slug[0].constantize.accessible_by(current_ability)
    if slug[0] == 'Category'
      options = (params[:subset] == "true") ? options.sub_categories : options.main_categories
    else
      options = options.select_options
    end
    options = options.is_sms_based if slug[0] == 'Client' && params[:sms_based] == "true"
    options = options.where(msp_id: params[:msp_id]) if params[:msp_id].present?
    render :json => options.map{|c|{id: c.id, name: c.send(slug[1])}}
  end

  
end
