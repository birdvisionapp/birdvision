class AuthController < ApplicationController

  before_filter :find_client, :only => [:authorize, :check_token]

  before_filter :check_redirect_uri, :check_participant_scope, :only => :authorize

  before_filter :authenticate_client, :only => :access_token

  def authorize
    AccessGrant.prune!
    access_grant = @user.access_grants.create({:client => @client, :state => params[:state]}, :without_protection => true)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    access_grant = AccessGrant.authenticate(params[:code], @client.id)
    unless access_grant.present?
      render :json => json_status(1, 'Could not authenticate access code')
      return
    end
    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def failure
    render :text => "ERROR: #{params[:message]}"
  end

  def user
    hash = {
      :provider => 'bvc',
      :id => current_user.id.to_s,
      :info => {
        :username  => current_user.username,
        :email     => current_user.email
      },
      :extra => {
        :full_name  => current_user.full_name
      }
    }
    render :json => hash.to_json
  end

  def check_token
    access_grant = AccessGrant.where({:client_id => @client.id, :access_token => params[:access_token]}).first
    unless access_grant.present?
      render :json => json_status(1, 'Could not authenticate access token')
      return
    end
    sign_in access_grant.user
    redirect_to default_landing_path and return
  end

  private

  def find_client
    @client ||= Client.where(:client_key => params[:client_id]).first
    unless @client.present?
      render :json => json_status(1, 'Invalid client id')
      return
    end
  end

  def authenticate_client
    @client ||= Client.authenticate(params[:client_id], params[:client_secret])
    unless @client.present?
      render :json => json_status(1, 'Invalid client id or client secret')
      return
    end
  end

  def check_redirect_uri
    unless params[:redirect_uri].present?
      render :json => json_status(1, 'Please present the redirect uri / callback url')
      return
    end
  end

  def check_participant_scope
    unless params[:scope].present? && params[:scope][:participant_id].present?
      render :json => json_status(1, 'Please present the ParticipantID in scope')
      return
    end
    username = User.build_username_with_participant(@client.code, params[:scope][:participant_id])
    @user ||= @client.users.where(:username => username).first
    unless @user.present?
      render :json => json_status(1, "Could not find BVC user account with ParticipantID: #{params[:scope][:participant_id]}")
      return
    end
    unless @user.status.downcase == User::Status::ACTIVE
      render :json => json_status(1, "The participant is in #{@user.status.upcase} status")
      return
    end
  end

end