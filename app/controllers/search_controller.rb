class SearchController < ApplicationController
  include UserCatalogHelper
  include PointRangeCalculator
  before_filter :authenticate_user!

  def search_catalog
    search_params = refine_params((params[:search] || {}).merge(:page => params[:page]))
    @search = Search.new(search_params)
    unless  @search.valid?
      flash[:alert]= App::Config.errors[:search][:search_criteria_not_defined]
      redirect_to catalog_path_for(@user_scheme) and return
    end

    search_criteria = SolrWrapper.search_catalog(@search, current_user, @user_scheme)

    @results = search_criteria.results
    @catalogs = @user_scheme.catalogs

    search_stats = search_criteria.stats_by(:points).present? ? search_criteria.stats_by(:points).slice("min","max") : {}

    @point_range = point_range_for(@user_scheme, search_stats, search_params)
    @show_point_filter = (@point_range[:min] != @point_range[:max]) && @user_scheme.show_points?
    extract_search_results(search_criteria)
    render :show
  end

  private

  def extract_search_results(search_criteria)
    flash.now[:alert] = App::Config.errors[:search][:keyword_not_found] % params[:search][:keyword] and return if @results.empty?
    @categories = search_criteria.facet_by(:category)
    @parent_category = search_criteria.facet_by(:parent_category)
    @total_count = search_criteria.total
  end

  def refine_params(params = {})
    if params[:category].present? && params[:category].match(/[(\d)]/)
      params.merge!(:category => params[:category].gsub!(/[(\d)]/, "").strip)
    end
    return params
  end

end