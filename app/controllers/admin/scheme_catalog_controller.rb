class Admin::SchemeCatalogController < Admin::AdminController
  authorize_resource :class => Scheme

  include AverageMarginCalculator

  def show
    @scheme = Scheme.accessible_by(current_ability).find(params[:id])
    respond_to do |format|
      format.html {
        @search = @scheme.catalog.catalog_items.includes(:client_item => [:level_clubs => [:level, :club],
            :client_catalog => :client,
            :item => [:category, {:preferred_supplier => :supplier}]]).active_item.search(params[:q])
        @catalog_items = @search.result.page(params[:page]).per(10)
        @average_client_margin = client_margin_for_catalog_items @search.result
        flash.now[:info] = App::Config.messages[:scheme_catalog][:empty_catalog] if params[:q].nil? && @catalog_items.empty?
      }
      format.csv {
        process_csv_report("Scheme Catalog for #{@scheme.name} till #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "Scheme.accessible_by(current_ability).where(id: #{@scheme.id}).first.catalog.catalog_items.includes(:client_item => [:level_clubs => [:level, :club],:client_catalog => :client, :item => [:category, {:preferred_supplier => :supplier}]]).active_item.search(#{params[:q]})")
      }
    end
  end

  def edit
    @scheme = Scheme.accessible_by(current_ability).find(params[:id])
    @search = @scheme.client.client_items.exclude_exist(@scheme.catalog.catalog_items.pluck(:client_item_id)).includes(:schemes, :client_catalog, :item => [:category, {:preferred_supplier => :supplier}]).active_items.active_item.search(params[:q])
    @client_items = @search.result.page(params[:page]).per(10)
    flash.now[:info] = App::Config.messages[:scheme_catalog][:empty_client_catalog] if params[:q].nil? && @client_items.empty?
  end

  def update
    @scheme = Scheme.accessible_by(current_ability).find(params[:id])
    client_item_ids = params[:client_item_ids]
    if params[:select_all] == "true"
      search = @scheme.client.client_items.select('client_items.id').exclude_exist(@scheme.catalog.catalog_items.pluck(:client_item_id)).includes(:schemes, :client_catalog, :item => [:category, {:preferred_supplier => :supplier}]).active_items.active_item.search(params[:q])
      client_item_ids = search.result.map(&:id)
    end
    return redirect_to edit_admin_scheme_catalog_path(@scheme), :alert => App::Config.messages[:scheme_catalog][:empty_selection] unless client_item_ids.present?
    client_items = ClientItem.find(client_item_ids)
    @scheme.catalog.add(client_items)
    @scheme.level_clubs.first.catalog.add(client_items) if @scheme.is_1x1?
    flash[:notice] = App::Config.messages[:scheme_catalog][:adding_items] % [client_items.length, @scheme.name]
    flash.keep
    redirect_to :action => :show
  end

  def remove_item
    scheme = Scheme.accessible_by(current_ability).find(params[:id])

    client_item = ClientItem.find(params[:client_item_id])
    scheme.remove(client_item)
    flash[:notice] = App::Config.messages[:scheme_catalog][:remove_item] % [client_item.title, scheme.name.titleize]
    flash.keep
    redirect_to :action => :show, :q => params[:q]
  end

end