class CatalogsController < ApplicationController
  before_filter :authenticate_user!, :assign_default_attrs

  def index
    redirect_to :action => :show, :id => @catalogs.first.id, :scheme_slug => params[:scheme_slug] and return if @catalogs.single_catalog?
    @point_range = @catalogs.point_range
  end

  def show
    @club_catalog = @catalogs.club_catalog(params[:id])
    redirect_to catalogs_path and return if @club_catalog.nil?
    @point_range = @catalogs.point_range
    @client_items = @club_catalog.items.page(params[:page])
  end

  def assign_default_attrs
    @catalogs = @user_scheme.catalogs
  end
end