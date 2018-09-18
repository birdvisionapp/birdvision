class Admin::LevelClubCatalogController < Admin::AdminController

  include AverageMarginCalculator

  def show
    @level_club = LevelClub.accessible_by(current_ability).find(params[:id])
    @search = @level_club.catalog.catalog_items.active_item.includes(:client_item => [:client_catalog => :client,
                                                                          :item => [:category, {:preferred_supplier => :supplier}]]).search(params[:q])
    @catalog_items= @search.result.page(params[:page]).per(10)
    @average_client_margin = client_margin_for_catalog_items @search.result
    flash.now[:info] = App::Config.messages[:level_club_catalog][:empty_catalog] if params[:q].nil? && @catalog_items.empty?

  end

  def edit
    @level_club = LevelClub.find(params[:id])
    @search = @level_club.scheme.active_items.exclude_exist(@level_club.catalog.catalog_items.pluck(:client_item_id)).includes(:level_clubs => [:level, :club],
                                                       :client_catalog => :client,
                                                       :item => [:category, {:preferred_supplier => :supplier}]).search(params[:q])
    @client_items = @search.result.page(params[:page]).per(10)
    flash.now[:info] = App::Config.messages[:level_club_catalog][:empty_scheme_catalog] if params[:q].nil? && @client_items.empty?
  end

  def update
    @level_club = LevelClub.find(params[:id])
    client_item_ids = params[:client_item_ids]
    if params[:select_all] == "true"
      search = @level_club.scheme.active_items.select('client_items.id').exclude_exist(@level_club.catalog.catalog_items.pluck(:client_item_id)).includes(:level_clubs => [:level, :club], :client_catalog => :client, :item => [:category, {:preferred_supplier => :supplier}]).search(params[:q])
      client_item_ids = search.result.map(&:id)
    end
    unless client_item_ids.present?
      return redirect_to edit_admin_level_club_catalog_path(@level_club), :alert => App::Config.messages[:level_club_catalog][:empty_selection]
    end
    client_items = ClientItem.find(client_item_ids)
    unless @level_club.can_add?(client_items)
      return redirect_to edit_admin_level_club_catalog_path(@level_club), :alert => App::Config.messages[:level_club_catalog][:error_adding_items] % [@level_club.level_name.titleize, @level_club.scheme.name]
    end
    @level_club.catalog.add(client_items)
    flash[:notice]= App::Config.messages[:level_club_catalog][:add_items] % [client_items.size, @level_club.scheme.name, @level_club.level_name.titleize]
    redirect_to :action => :show
  end

  def remove_item
    level_club = LevelClub.find(params[:id])
    client_item = ClientItem.find(params[:client_item_id])
    level_club.remove(client_item)
    flash[:notice] = App::Config.messages[:level_club_catalog][:remove_item] % [client_item.title, level_club.scheme.name, level_club.name.titleize]
    flash.keep
    redirect_to :action => :show, :q => params[:q]
  end
end