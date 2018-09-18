class Admin::AdminController < ApplicationController
  layout "admin"
  respond_to :html
  before_filter :authenticate_admin_user!
  helper_method :is_client_manager?, :is_super_admin?, :is_msp_admin?, :is_admin_user?, :can_manage_roles?, :is_representative?
  helper_method :current_client
  helper_method :ancestry_options

  private

  def is_client_manager?
    current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
  end

  def is_representative?
    current_admin_user.role == AdminUser::Roles::REPRESENTATIVE
  end

  def is_super_admin?
    is_admin_user? && !current_admin_user.msp_id.present?
  end

  def is_msp_admin?
    is_admin_user? && current_admin_user.msp_id.present?
  end

  def is_admin_user?
    current_admin_user.super_admin?
  end

  def can_manage_roles?
    is_admin_user? && current_admin_user.manage_roles?
  end

  def process_csv_report(filename, options = {})
    ActiveRecord::Base.uncached do
      report = current_admin_user.download_reports.create(:filename => filename, :status => DownloadReport::Status::PROCESSING)
      report.delay.process(options)
    end
    redirect_to admin_download_reports_path
  end

  def current_client
    @current_client ||= ClientManager.associated_client_for(current_admin_user) if is_client_manager?
  end

  def ancestry_options(items, json = false)
    result = []
    items.map do |item|
      result << [item.send((!is_admin_user? or json) ? :name : :display_with_client), item.id]
      result += item.children.map {|sr| ["&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;#{sr.name}".html_safe, sr.id]} if item.children.present?
    end
    result
  end

  def user_role_tree(id)
    result = []
    user_role = UserRole.accessible_by(current_ability).find(id)
    if user_role.present?
      result = user_role.subtree_ids
    end
    result
  end

  def load_user_roles
    @user_roles = ancestry_options(UserRole.includes(:client).accessible_by(current_ability).main_roles.select_options)
  end

  def load_telecom_regions
    @telecom_regions = telecom_region_options(RegionalManager.includes(:client).accessible_by(current_ability).select_options)
  end

  def telecom_region_options(items, json = false)
    items.map{|item| [item.send((!is_admin_user? or json) ? :region : :region_with_client), item.id] }
  end

  def load_telecom_circles
    @telecom_circles = TelecomCircle.accessible_by(current_ability).select([:id, :description]).all
  end

  def init_includes(includes = [])
    includes << {:client => :msp} if is_super_admin?
    includes
  end

  def set_msp(object)
    msp_id = object.msp_id
    object.msp_id = (is_msp_admin?) ? current_admin_user.msp_id : msp_id
  end
  
end
