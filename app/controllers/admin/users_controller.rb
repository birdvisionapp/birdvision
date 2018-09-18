class Admin::UsersController < Admin::AdminController

  before_filter :load_telecom_circles, :only => [:edit, :update]

  load_and_authorize_resource

  inherit_resources
  include Admin::UsersHelper
  actions :all, :except => [:destroy, :new]
  defaults :resource_class => User

  before_filter :load_user_roles, :only => [:index, :import_csv, :upload_csv]

  before_filter :load_telecom_regions, :only => :index

  def index
    default_sort = 'users.updated_at desc'
    respond_to do |format|
      format.html {
        model = User.includes(:client => :msp, :telecom_circle => :regional_managers, :user_schemes => :scheme).accessible_by(current_ability)
        model = model.region_scope if params[:q] && params[:q][:telecom_circle_regional_managers_id_eq].present?
        @search = model.select('users.id, users.participant_id, users.username, users.full_name, users.email, users.mobile_number, users.activation_status, users.status, users.created_at, users.client_id, users.telecom_circle_id').search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @users_stats = @search.result.group(:activation_status).count
        @client_stats = @search.result.group('clients.client_name').count if is_admin_user?
        @users = @search.result(:distinct => true).page(params[:page])
      }
      format.csv {
        process_csv_report("Participants Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "User.includes(:user_role, :client => :msp, :telecom_circle => :regional_managers, :user_schemes => :scheme).accessible_by(current_ability).select('users.id, users.participant_id, users.username, users.full_name, users.email, users.mobile_number, users.activation_status, users.status, users.created_at, users.client_id, users.telecom_circle_id, users.user_role_id, users.address, users.pincode, users.notes, users.landline_number')#{(params[:q] && params[:q][:telecom_circle_regional_managers_id_eq].present?) ? '.region_scope' : ''}.search(#{params[:q]})")
      }
    end
  end

  def edit
    @user = User.find(params[:id])
    @is_sms_based = (params[:sms_based_registration] == "true") ? true : false
  end

  def upload_csv
    async_job = current_admin_user.async_jobs.create(:job_owner => User.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
    if (!params[:category].present? or !params[:scheme].present? or !params[:csv].present? or !async_job.valid?)
      flash.now[:alert] = App::Config.messages[:admin_participants][get_flash_alert]
      render :action => :import_csv
    else
      async_job.delay.execute(params[:scheme], {:add_points => (params[:add_points] == 'true'), :category => params[:category]})
      flash[:notice] = App::Config.messages[:user][:processed_successfully]
      redirect_to admin_uploads_index_path
    end
  end

  def send_activation_email_to
    user_ids = params[:user_ids]
    if params[:select_all] == "true"
      search = User.accessible_by(current_ability).search(params[:q])
      user_ids = search.result(:distinct => true).pluck('users.id')
    end
    action = 'activation' if params[:send_activation_link]
    action = 'active' if params[:active]
    action = 'inactive' if params[:inactive]
    participant_group_action(user_ids, action) unless action.nil?
    flash.keep
    redirect_to admin_users_path(:q => params[:q])
  end

  def al_csv_template
    respond_to { |format|
      format.csv { send_data AlUserCsv.new(current_admin_user).template, :filename => "AL DOST PROGRAM csv template.csv" }
    }
  end

  private

  def participant_group_action(user_ids, message_slug)
    if user_ids.nil?
      flash[:alert] = App::Config.messages[:admin_participants]["no_users_selected_for_#{message_slug}".to_sym]
    else
      (message_slug == 'activation') ? email_password_reset_instructions_to(user_ids) : User.where(['id IN(?)', user_ids]).update_all({:status => message_slug, :activation_status => ''})
      flash[:notice] = App::Config.messages[:admin_participants]["successful_#{message_slug}".to_sym] % user_ids.length
    end
  end

  def get_flash_alert
    if !params[:category].present?
      flash_alert = :category_not_selected
    elsif !params[:scheme].present?
      flash_alert = :scheme_not_selected
    elsif !params[:csv].present?
      flash_alert = :file_not_provided
    else
      flash_alert = :invalid_file
    end
    flash_alert
  end

end
