<% if @reward_item_point.errors.any? -%>
  $("#reward-item-point-errors").html("<%= escape_javascript(render("share/messages", :type => :alert, :message => @reward_item_point.errors.full_messages))%>");
  $("#reward-item-point-errors").show();
<% else -%>
  $("#reward-item-point-errors").hide();
  $("#clnt-pp-tiers-prev-form").html("<%= escape_javascript(render("preview_tier_conf", :reward_item_point => @reward_item_point)) %>");
  $("#clnt-pp-tiers-prev-form").show();
  $("#clnt-pp-tiers-edit-form").html("<%= escape_javascript(render("tiers_form", :product_pack => @reward_item_point)) %>");
  $('#clnt-pp-tiers-edit-form').hide();
<% end -%>