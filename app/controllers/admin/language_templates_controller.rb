class Admin::LanguageTemplatesController < Admin::AdminController
  
  load_and_authorize_resource

  inherit_resources

  def index
    @search = LanguageTemplate.accessible_by(current_ability).select([:id, :name, :template, :status, :created_at]).search(params[:q])
    @search.sorts = 'created_at asc' if @search.sorts.empty?
    @language_templates = @search.result.page(params[:page])
  end

  def update
    update!{ admin_language_templates_path }
  end

  private

  def interpolation_options
    {:resource_description => @language_template.name}
  end

end