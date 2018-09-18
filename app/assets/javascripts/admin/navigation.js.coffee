$(document).ready ->
  $("#bvc-admin-main-navbar").on "focus mouseenter mouseleave click", "ul.nav li", (event) ->
    $(this).find(".dropdown-menu").show()
    $(this).addClass "open"
    if event.type is "mouseleave"
      $(this).find(".dropdown-menu").hide()
      $(this).removeClass "open"

  $("#bvc-admin-main-navbar").on "click", "ul.nav li ul.dropdown-menu", (event) ->
    $(this).css("margin-top", -1)
    $(this).parent().addClass("active")