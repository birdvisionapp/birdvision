class Admin::UserManagement::RepresentativesController < Admin::UserManagement::ClientAdminController

  load_and_authorize_resource

  defaults :resource_class => Representative, :instance_name => 'resource'

  before_filter :load_linked_users, :only => [:show, :edit, :update]

  before_filter :load_user_roles, :only => [:edit, :update, :show]

  before_filter :assign_users, :only => [:show, :edit]

  def edit
    
  end

  def update
    if params[:add_participants]
      user_ids = params[:user_ids]
      if params[:select_all] == "true"
        user_ids = @search.result.map(&:id)
      end
      return redirect_to edit_admin_user_management_representative_path(:q => params[:q]), :alert => 'Please select at least one Participant' unless user_ids.present?
      @resource.users << User.where(id: user_ids).select(:id)
    end
    update!
  end

  def unlink_user
    rep_link = RegionalManagersUser.by_resource(params[:user_id], params[:resource_id])
    rep_link.delete_all
    respond_to do |format|
      format.html { redirect_to admin_user_management_representatives_path }
      format.js   { render :nothing => true }
    end
  end

  private

  def load_linked_users
    @client = @resource.client
    @linked_search = @resource.users.accessible_by(current_ability).select('users.id, users.full_name, users.username, users.mobile_number').search(params[:q])
    @search = @client.users.no_links.accessible_by(current_ability).select('users.id, users.full_name, users.username, users.mobile_number').search(params[:q])
  end

  def load_user_roles
    @user_roles = ancestry_options(@client.user_roles.main_roles.accessible_by(current_ability).select_options, true)    
  end

  def assign_users
    @users = @search.result.page(params[:page])
    @linked_users = @linked_search.result
  end
  
end
