class Admin::SchemesController < Admin::AdminController

  load_and_authorize_resource
  skip_authorize_resource :only => [:download_report, :csv_template, :list_for_client]

  inherit_resources
  actions :all, :except => [:destroy, :show]

  def index
    @search = Scheme.includes(init_includes).accessible_by(current_ability).select('schemes.id, schemes.name, schemes.client_id, schemes.start_date, schemes.end_date, schemes.redemption_start_date, schemes.redemption_end_date').search(params[:q])
    @schemes = @search.result.order("schemes.created_at desc").page(params[:page])
  end

  def download_report
    scheme = Scheme.includes(:client => :msp).accessible_by(current_ability).select([:id, :name, :client_id]).find(params[:scheme_id])
    respond_to do |format|
      format.html { redirect_to admin_schemes_path }
      format.csv {
        process_csv_report("#{scheme.client.client_name.titleize} - #{scheme.name.titleize} #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model: 'Scheme', resource_id: scheme.id)
      }
    end
  end

  def create
    level_club_config = params.extract!(:level_club_config)
    @scheme = Scheme.new(params["scheme"])
    @scheme.create_level_clubs(level_club_config[:level_club_config][:level_name].reject(&:empty?).presence,
      level_club_config[:level_club_config][:club_name].reject(&:empty?).presence)
    if @scheme.save
      redirect_to admin_schemes_path, :notice => t(:notice, interpolation_options.merge(:scope => [:flash, :admin, :schemes, :create])) and return
    end
    render :new
  end

  def update
    update! { admin_schemes_path }
  end

  def csv_template
    scheme = Scheme.accessible_by(current_ability).find(params[:scheme_id])
    respond_to { |format|
      format.csv { send_data CsvUser.new(scheme).template, :filename => "#{scheme.name.titleize} csv template.csv" }
    }
  end

  def list_for_client
    is_template = params[:template].present? ? true : false
    schemes = Scheme.accessible_by(current_ability).select_options
    schemes = schemes.for_client(params[:client_id]) if params[:client_id].present?
    render :json => schemes.map{|s|
      result = {name: s.name, id: s.id, data_parent: s.client_id}
      result.merge!(data_template: admin_scheme_csv_template_path(s, :csv)) if is_template
      result
    }
  end

  private
  def interpolation_options
    {:resource_description => @scheme.name}
  end

end
