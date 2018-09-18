class ErrorsController < ApplicationController
  layout :error_layout

  def not_found
    @hide_search = true
    @error = 404
    @type = "Page Not Found"
    @message = "The Page you are looking for does not exist or is no longer available."
    render :template => 'errors/error_page', :status => 404, :formats => [:html]
  end

  def server_error
    @hide_search = true
    @error = 500
    @type = "Something Went Wrong"
    @message = "We are sorry but there was an error. Please try again later."
    render :template => 'errors/error_page', :status => 500, :formats => [:html]
  end

  private
  def error_layout
    current_admin_user.present? ? "admin" : "application"
  end
end