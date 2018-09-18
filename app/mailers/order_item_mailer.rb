class OrderItemMailer < ActionMailer::Base
  helper :mail_url
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def shipped order_item, options = {}
    sendgrid_category 'Participant Order Shipment'
    sendgrid_unique_args :order => order_item.order.order_id, :scheme => order_item.scheme.name, :order_item => order_item.id
    @order_item = order_item
    @scheme = order_item.scheme
    @options = options
    mail :to => @order_item.order.user.email, :subject => "#{@order_item.order.user.client.client_name} Rewards Program - Shipment of Item in Order #{@order_item.order.order_id}", :template_path => "mailers/order_item"
  end

  def delivered order_item, options = {}
    sendgrid_category 'Participant Order Delivery'
    sendgrid_unique_args :order => order_item.order.order_id, :scheme => order_item.scheme.name, :order_item => order_item.id
    @order_item = order_item
    @scheme = order_item.scheme
    @options = options
    mail :to => @order_item.order.user.email, :subject => "#{@order_item.order.user.client.client_name} Rewards Program - Delivery of item in Order #{@order_item.order.order_id}", :template_path => "mailers/order_item"
  end

  def refunded order_item, options = {}
    sendgrid_category 'Participant Order Refund'
    sendgrid_unique_args :order => order_item.order.order_id, :scheme => order_item.scheme.name, :order_item => order_item.id
    @order_item = order_item
    @scheme = order_item.scheme
    @options = options
    mail :to => @order_item.order.user.email, :subject => "#{@order_item.order.user.client.client_name} Rewards Program - Refund of item in Order #{@order_item.order.order_id}", :template_path => "mailers/order_item"
  end

  def to_shipped gift, gift_name
    sendgrid_category 'Participant Gift Shipment'
    sendgrid_unique_args :gift => gift, :gift_name => gift_name
    @gift = gift
    @gift_name = gift_name
    mail :to => @gift.user.email, :subject => "#{@gift.user.client.client_name} Rewards Program - Shipment of Gift", :template_path => "mailers/order_item"
  end

  def to_delivered gift, gift_name
    sendgrid_category 'Participant Gift Delivery'
    sendgrid_unique_args :gift => gift, :gift_name => gift_name
    @gift = gift
    @gift_name = gift_name
    mail :to => @gift.user.email, :subject => "#{@gift.user.client.client_name} Rewards Program - Delivery of Gift", :template_path => "mailers/order_item"
  end

end
