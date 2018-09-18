class Admin::SmsBased::UsersController < Admin::AdminController
  

  def index
    @search = User.includes(:client, :unique_item_codes, :telecom_circle => :regional_managers).sms_based.pending.accessible_by(current_ability).search(params[:q])
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @users = @search.result.page(params[:page])
  end

  def login
    if current_admin_user.client_manager.present?
      client = current_admin_user.client_manager.client
      @user = User.accessible_by(current_ability).where(:username => User.build_username_with_participant(client.code, params[:participant_id])).first
    elsif current_admin_user.representative.present?
      client = current_admin_user.representative.client
      @user = User.accessible_by(current_ability).where(:username => User.build_username_with_participant(client.code, params[:participant_id])).first
    elsif current_admin_user.regional_manager.present?
      client = current_admin_user.regional_manager.client
      @user = User.accessible_by(current_ability).where(:username => User.build_username_with_participant(client.code, params[:participant_id])).first
    end
    if @user.present?
      unless @user.status.downcase == User::Status::ACTIVE
        flash.now[:alert] = "Participant is #{@user.status.upcase} Status"
      else
        sign_in @user
        redirect_to default_landing_path and return
      end
    elsif params[:participant_id].present?
      flash.now[:alert] = "Invalid Participant ID"
    end
  end
  
end


