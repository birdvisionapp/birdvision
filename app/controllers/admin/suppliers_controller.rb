class Admin::SuppliersController< Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :all, :except => [:destroy, :show]

  def index
    @search = Supplier.accessible_by(current_ability).select('suppliers.id, suppliers.name, suppliers.address, suppliers.phone_number, suppliers.supplied_categories, suppliers.geographic_reach, suppliers.msp_id').search(params[:q])
    @suppliers = @search.result.order("suppliers.created_at desc").page(params[:page])
  end

  private
  def interpolation_options
    {:resource_description => @supplier.name}
  end

end
