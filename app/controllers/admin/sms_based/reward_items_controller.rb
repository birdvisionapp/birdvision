class Admin::SmsBased::RewardItemsController < Admin::AdminController
  
  load_and_authorize_resource

  inherit_resources

  skip_authorize_resource :only => [:list_for_scheme]

  actions :all, :except => [:destroy]

  def index
    default_sort = 'created_at desc'
    respond_to do |format|
      format.html {
        @search = RewardItem.includes(init_includes([:reward_item_points, :scheme])).accessible_by(current_ability).select('reward_items.id, reward_items.name, reward_items.status, reward_items.created_at, reward_items.client_id, reward_items.scheme_id').search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @reward_items = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("Reward Products Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "RewardItem.includes([:reward_item_points, :scheme, :client => :msp]).accessible_by(current_ability).select('reward_items.id, reward_items.name, reward_items.status, reward_items.created_at, reward_items.client_id, reward_items.scheme_id').search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

  def new
    @reward_item.reward_item_points.build
  end

  def list_for_scheme
    products = RewardItem.accessible_by(current_ability).select_options
    products = products.where('scheme_id = ?',  params[:scheme_id]) if params[:scheme_id].present?
    products = products.where('client_id = ?',  params[:client_id]) if params[:client_id].present?
    render :json => products.map{|p|
      result = {id: p.id, name: p.name, data_parent: p.scheme_id}
      result
    }
  end
  
  private
  
  def interpolation_options
    {:resource_description => @reward_item.name}
  end

end


