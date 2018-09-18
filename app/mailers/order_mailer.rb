class OrderMailer < ActionMailer::Base
  helper :mail_url
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def point_redemption order, scheme, order_items, total_points
    sendgrid_category 'Participant Order Confirmation'
    sendgrid_unique_args :order => order.order_id, :scheme => scheme.name
    @order = order
    @scheme = scheme
    @order_items = order_items
    @total_points = total_points
    mail :to => @order.user.email, :subject => "#{@order.user.client.client_name} Rewards Program - Order Confirmation", :template_path => "mailers/order"
  end
end
