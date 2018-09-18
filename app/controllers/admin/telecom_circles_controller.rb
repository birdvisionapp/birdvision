class Admin::TelecomCirclesController < Admin::AdminController
  
  load_and_authorize_resource

  inherit_resources

  def index
    @search = TelecomCircle.accessible_by(current_ability).select([:id, :code, :description, :created_at]).search(params[:q])
    @search.sorts = 'code asc' if @search.sorts.empty?
    @telecom_circles = @search.result.page(params[:page])
  end

  def create
    create!{ admin_telecom_circles_path }
  end

  def update
    update!{ admin_telecom_circles_path }
  end

  private

  def interpolation_options
    {:resource_description => @telecom_circle.code}
  end

end