class Admin::RewardProductCatagoriesController < Admin::AdminController

  layout "admin"
  
  before_filter :authenticate_admin_user!
  
  def index
    @reward_product_catagories = RewardProductCatagory.accessible_by(current_ability)
  end

  def new
    @reward_product_catagory = RewardProductCatagory.new
  end

  def create
    @reward_product_catagory = RewardProductCatagory.new(params["reward_product_catagory"])
    if @reward_product_catagory.save
      flash[:notice] = "Catagory successfully added to your list"
      redirect_to admin_reward_product_catagories_path and return
    end
    render :new
  end

  def edit
    @reward_product_catagory = RewardProductCatagory.find(params[:id])
  end

  def update
    @reward_product_catagory = RewardProductCatagory.find(params[:id])
    if @reward_product_catagory.update_attributes(params["reward_product_catagory"])
      flash[:notice] = "Catagory successfully updated"
      redirect_to admin_reward_product_catagories_path and return
    end
    render :edit
  end

  def delete
  end

  def list_for_product_categories
    categories = RewardProductCatagory.accessible_by(current_ability).select_categories
    categories = categories.for_scheme(params[:scheme_id]) if params[:scheme_id].present?
    render :json => categories.map{|s|
      result = {name: s.category_name, id: s.id, data_parent: s.scheme_id}
      result
    }
  end

end