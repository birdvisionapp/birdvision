class Admin::TargetedOffersController < ApplicationController
  
  before_filter :authenticate_admin_user!
  
  layout 'admin'
    
  def index
    @search = Client.accessible_by(current_ability).search(params[:q])
    @clients = @search.result.order("created_at desc").page(params[:page]).where(:is_targeted_offer_enabled => true)
    
  end

  def show
    @client = Client.find(params[:id])
    @offers = @client.templates
  end

  def create
    @client_toc = ClientsTemplate.new
    @client_toc.template_id = params[:template_id]
    @client_toc.client_id = params[:client_id]
    @check = ClientsTemplate.where('template_id = ? and client_id = ?', params[:id],params[:client_id])
    if @check.empty?
      if @client_toc.save
        flash[:notice] = "Targeted offer successfully added"
      else
        flash[:alert] = "Targeted offer not successfully added"
      end
    else
      flash[:alert] = "Targeted offer already exist"
    end
    redirect_to add_offers_admin_targeted_offers_path(:client_id => params[:client_id])
  end

  def destroy
    @check = ClientsTemplate.where('template_id = ? and client_id = ?', params[:id], params[:client_id])
    ClientsTemplate.destroy(@check)
    flash[:notice] = "Targeted offer successfully deleted"
    redirect_to admin_targeted_offer_path(:id => params[:client_id])
  end

  def add_offers
    @search = TargetedOfferType.accessible_by(current_ability).search(params[:q])
    @to_type = @search.result.page(params[:page])
    @not_added_offer = Array.new
    @client = Client.find(params[:client_id])
    @client_offers = @client.templates
    @targeted_offers = Template.all
    @targeted_offers.each do |to|
      unless @client_offers.include?(to)
        @not_added_offer << to
      end
    end
    @not_added_offer
  end
  
end
