class Admin::ClientCatalogController < Admin::AdminController
  include AverageMarginCalculator
  authorize_resource
  inherit_resources
  actions :all, :except => [:destroy]
  defaults :resource_class => ClientItem, :collection_name => 'client_items', :instance_name => 'client_item'

  def show
    @client = Client.accessible_by(current_ability).find(params[:id])
    default_sort = 'client_items.updated_at desc'
    respond_to do |format|
      format.html {
        @search = @client.client_items.available.active_item.joins(:item => :preferred_supplier).includes(:schemes, :client_catalog, :item => [:category, {:preferred_supplier => :supplier}]).search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @client_items = @search.result.page(params[:page]).per(10)
        @average_client_margin = client_margin_for_client_items @search.result
        flash.now[:info] = App::Config.messages[:client_catalog][:empty_catalog] if params[:q].nil? && @client_items.empty?
      }
      format.csv {
        process_csv_report("Client Catalog for #{@client.client_name} #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "Client.accessible_by(current_ability).where(id: #{@client.id}).first.client_items.available.active_item.joins(:item => :preferred_supplier).includes(:schemes, :client_catalog, :item => [:category, {:preferred_supplier => :supplier}]).search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

  def edit
    @client = Client.accessible_by(current_ability).find(params[:id])
    items_que = Item.accessible_by(current_ability).exclude_exist(@client.client_items.available.pluck(:item_id)).includes(:category => :msp, :preferred_supplier => :supplier).order("items.updated_at desc").active_items.active
    items_que = items_que.client_items_avail if params[:q] && params[:q][:client_items_client_id_eq].present?
    items_que = items_que.where("categories.msp_id = ?", @client.msp_id) if @client.msp_id.present?
    @search = items_que.search(params[:q])
    @items = @search.result(:distinct => true).page(params[:page])
  end

  def update
    client = Client.accessible_by(current_ability).find(params[:id])
    item_ids = params[:item_ids]
    if params[:select_all] == "true"
      search = Item.accessible_by(current_ability).exclude_exist(client.client_items.available.pluck(:item_id)).active_items.active.search(params[:q])
      item_ids = search.result(:distinct => true).pluck('items.id')
    end
    return redirect_to edit_admin_client_catalog_path(client.id), :alert => App::Config.messages[:client_catalog][:empty_selection] unless item_ids.present?
    (item_ids.length > 40) ? client.delay.add_to_catalog(item_ids) : client.add_to_catalog(item_ids)
    flash[:notice] = App::Config.messages[:client_catalog][:adding_items] % [item_ids.length, client.client_name]
    flash.keep
    redirect_to admin_client_catalog_path(client.id)
  end

  def remove_item
    client_item = ClientItem.find(params[:client_item_id])
    level_clubs = client_item.level_clubs.joins(:catalog_items).where(:catalog_items => {:client_item_id => client_item.id}).to_a
    client_item.soft_delete

    flash[:notice] = (successfully_deleted_message(client_item) + deleted_from_level_club_catalogs_message(level_clubs)).html_safe
    flash.keep
    redirect_to admin_client_catalog_path(params[:id], :q => params[:q])
  end

  private
  def successfully_deleted_message(client_item)
    App::Config.messages[:client_catalog][:removed_client_item] % [client_item.item.title, client_item.client.client_name]
  end

  def deleted_from_level_club_catalogs_message(level_clubs)
    return "" if level_clubs.empty?
    "<br>" + App::Config.messages[:client_catalog][:removed_from_level_club_catalogs_message] % level_clubs.collect(&:name).join(" and ")
  end
end
