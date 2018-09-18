class Admin::CategoriesController < Admin::AdminController
  load_and_authorize_resource
  inherit_resources
  #defaults :finder => :find_by_slug
  actions :all, :except => [:destroy, :show]
  before_filter :identify_type

  def index
    @search = Category.accessible_by(current_ability).main_categories.order("lower(title)").select_options_list.search(params[:q])
    @main_categories = @search.result.page(params[:page])
    @sub_categories = Category.accessible_by(current_ability).sub_categories.select_options_list
  end

  def create
    set_msp(@category)
    @category.msp_id = @category.parent.msp_id if !@category.msp_id.present? && @category.parent.present?  && @category.parent.msp_id.present?
    create!
  end

  private
  
  def interpolation_options
    if @category.main?
      return {:resource_description => "category #{@category.title}"}
    end
    {:resource_description => "sub-category #{@category.title} under #{@category.parent.title}"}
  end

  def identify_type
    @type = params[:type]
    @is_subcategory_page = (@type == "subcat")
    @taxonomy_type = @is_subcategory_page ? "Subcategory" : "Category"
  end


end
