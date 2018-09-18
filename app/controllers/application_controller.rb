class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_cache_headers
  before_filter :reload_locales
  layout :layout_by_resource
  before_filter :find_current_user_scheme
  helper_method :default_landing_path, :client_for_host, :client_for_admin_user

  def reload_locales
    I18n.reload! if Rails.env.development?
  end

  private
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = 1.year.ago.to_s
  end

  def after_sign_in_path_for(resource_or_scope)
    @default_routes ||= {
      AdminUser::Roles::SUPER_ADMIN => admin_dashboard_path,
      AdminUser::Roles::RESELLER => admin_sales_reseller_dashboard_index_path,
      AdminUser::Roles::CLIENT_MANAGER => admin_dashboard_path,
      AdminUser::Roles::REGIONAL_MANAGER => admin_regional_dashboard_path,
      AdminUser::Roles::REPRESENTATIVE => admin_regional_dashboard_path
    }
    if resource_or_scope.is_a?(AdminUser)
      if resource_or_scope.role == AdminUser::Roles::CLIENT_MANAGER 
        dashboard_check = ClientManager.where("admin_user_id = ?", resource_or_scope.id).first.is_client_dashboard_unabled
        if dashboard_check
          default_path = admin_client_managers_widgets_path
        else  
          default_path = @default_routes[resource_or_scope.role]
        end
      else
        default_path = @default_routes[resource_or_scope.role]        
      end 
    else
      default_path = default_landing_path
    end
    # default_path = resource_or_scope.is_a?(AdminUser) ? @default_routes[resource_or_scope.role] : default_landing_path
    stored_location_for(resource_or_scope) || default_path
  end

  def after_sign_out_path_for(resource_or_scope)
    return new_admin_user_session_path if resource_or_scope == :admin_user
    return params[:redirect_uri] if params[:redirect_uri].present?
    default_sign_landing_path
  end

  def default_sign_landing_path
    if current_user && current_user.client && current_user.client.allow_sso? && current_user.client.client_url.present?
      return current_user.client.client_url
    end
    new_user_session_path
  end

  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user.try('username') : current_user.try('username')
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    flash.keep[:notice] = "You are not authorized to view this page."
    redirect_to new_admin_user_session_path
  end

  def layout_by_resource
    if devise_controller? && resource_name == :admin_user
      "admin"
    else
      "application"
    end
  end

  def find_current_user_scheme
    if current_user && params[:scheme_slug].present?
      @user_scheme ||= UserScheme.for_user(current_user, params[:scheme_slug]).first
      unless @user_scheme
        redirect_to default_sign_landing_path
      end
    end
  end

  def json_status(status_code, status_message)
    {title: get_status_title_with_code(status_code), status_code: status_code, status_message: status_message}
  end

  def get_status_title_with_code(code)
    case code
    when 0
      'ok'
    when 1
      'errors'
    when 2
      'exception'
    else
      'failed'
    end
  end

  def default_landing_path
    #return nil unless current_user
    if current_user
      (current_user.client.settings && current_user.client.settings[:scheme_catalog].present? && current_user.user_schemes.browsable.where(scheme_id: current_user.client.settings[:scheme_catalog].to_i).size > 0 ) ? view_context.catalog_path_for(current_user.user_schemes.browsable.where(scheme_id: current_user.client.settings[:scheme_catalog].to_i).first) : schemes_path
    else
      root_path
    end
  end

  def client_for_host
    (current_user.client if current_user.present?) || Client.where(:domain_name => "#{request.host}").first
  end

  def client_for_admin_user
    current_admin_user.send(current_admin_user.role).client if current_admin_user.present? && AdminUser::CLIENT_ADMINS.include?(current_admin_user.role)
  end

end