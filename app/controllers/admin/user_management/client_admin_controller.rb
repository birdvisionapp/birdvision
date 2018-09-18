class Admin::UserManagement::ClientAdminController < Admin::AdminController

  inherit_resources
  
  load_and_authorize_resource

  before_filter {
    @resource_name = resource_class.name.underscore.to_sym
  }
  
  before_filter :build_resource_name, :only => [:import_csv, :upload_csv, :csv_template]

  def index
    @search = resource_class.accessible_by(current_ability).available.includes(init_includes([:admin_user, :telecom_circles])).search(params[:q])
    @resources = @search.result.page(params[:page])
  end

  def create
    create! { 
      [:admin, :user_management, resource_class.name.underscore.pluralize.to_sym]
    }
  end

  def destroy
    resource_name = @resource.name
    @resource.admin_user.destroy
    flash[:notice] = App::Config.messages[resource_class.name.underscore.to_sym][:deleted] % [resource_name]
    redirect_to [:admin, :user_management, resource_class.name.underscore.pluralize.to_sym]
  end

  def import_csv
    
  end

  def upload_csv
    params[:client] = current_client.id if current_client.present?
    if (!params[:client].present? or !params[:csv].present?)
      flash.now[:alert] = App::Config.messages[:client_admin][get_flash_alert] % @resource_name.pluralize.titleize
      render :action => :import_csv, :resource => @resource_name
    else
      async_job = current_admin_user.async_jobs.create(:job_owner => ClientAdmin.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
      async_job.delay.execute(params[:client], {:resource => @resource_name})
      flash[:notice] = App::Config.messages[:client_admin][:processed_successfully]
      redirect_to admin_uploads_index_path
    end
  end

  def csv_template
    respond_to { |format|
      format.csv { send_data CsvClientAdmin.new(@resource_name).template, :filename => "#{@resource_name}-csv-template.csv" }
    }
  end


  private

  def build_resource_name
    @resource_name = params[:resource]
  end

  def get_flash_alert
    if !params[:client].present?
      flash_alert = :client_not_selected
    elsif !params[:csv].present?
      flash_alert = :file_not_provided
    else
      flash_alert = :invalid_file
    end
    flash_alert
  end

end
