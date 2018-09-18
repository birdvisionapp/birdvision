class Admin::WidgetsController < ApplicationController
  layout "admin"
  
  before_filter :authenticate_admin_user!
  
  def index
    @widgets = Widget.all
  end
  
  def edit
    
  end
end
