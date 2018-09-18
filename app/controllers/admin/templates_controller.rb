class Admin::TemplatesController < ApplicationController

before_filter :authenticate_admin_user!
  
  layout 'admin'
  
  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
  end

  def create
    if get_names.include?(params[:template][:name])
      flash[:alert] = "Name can not be same"
      redirect_to new_admin_template_path
    else
      @template = Template.new(params[:template])
      if @template.save
        flash[:notice] = "Template created successfully"
        redirect_to admin_templates_path
      else
        redirect_to new_admin_template_path
      end
    end
  end

  def destroy
    Template.find(params[:id]).destroy
    flash[:notice] = "Template deleted successfully"
    redirect_to admin_templates_path
  end

  def edit
      @template = Template.find(params[:id])
  end

  def update
      @template = Template.find(params[:id])
      if @template.update_attributes(params[:template])
        flash[:notice] = "Template updated successfully"
        redirect_to admin_templates_path
      else
        flash[:alert] = "Some values are missing "
        redirect_to edit_admin_template_path
      end
  end
  private
    
  def get_names
    @templates = Template.all
    names = Array.new
    @templates.each do |template|
      names << template.name
    end
    names
  end
end
