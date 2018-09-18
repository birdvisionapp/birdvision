class Admin::ClientItemController < Admin::AdminController
  load_and_authorize_resource


  def edit
    @client_item = ClientItem.find(params[:id])
  end

  def update
    @client_item = ClientItem.find(params[:id])
    unless @client_item.update_attributes(params[:client_item])
      return render :edit
    end
    flash[:notice] = "The Item %s was successfully updated" % @client_item.title
    redirect_to admin_client_catalog_path(:id => @client_item.client.id, :q => params[:q])
  end

end