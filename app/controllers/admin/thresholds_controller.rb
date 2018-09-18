class Admin::ThresholdsController < ApplicationController
  
  layout "admin"
  
  before_filter :authenticate_admin_user!
  
  def index
    @thresholds = Threshold.first    
  end
  
  def edit
    @thre = Threshold.first
    @threshold = Threshold.find(params[:id])
  end
  
  def update
    @threshold = Threshold.find(params[:id])
    if @threshold.update_attributes(params["threshold"])
      flash[:notice] = "Threshold value successfully updated"
      redirect_to admin_thresholds_path and return
    end
    render :edit
  end
end
