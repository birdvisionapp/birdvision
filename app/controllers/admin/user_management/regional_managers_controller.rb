class Admin::UserManagement::RegionalManagersController < Admin::UserManagement::ClientAdminController  

  load_and_authorize_resource

  before_filter :load_telecom_circles, :only => [:new, :create, :edit, :update]
  
  before_filter :assigned_telecom_circles, :only => [:new, :create, :edit, :update]

  defaults :resource_class => RegionalManager, :instance_name => 'resource'

  private

  def assigned_telecom_circles
    @assigned_telecom_circles = (params[:regional_manager] && params[:regional_manager][:telecom_circle_ids].present?) ? params[:regional_manager][:telecom_circle_ids].map(&:to_i) : RegionalManagersTelecomCircle.where(regional_manager_id: @regional_manager.id).select([:telecom_circle_id]).map(&:telecom_circle_id)
  end
  
end
