$(document).ready ->
  new TemplateWidget()


class @TemplateWidget
  constructor: ()->
    $('.template-action').click ->
      templateContainer = $(this).attr('rev')
      clone = $(templateContainer).find(".template").clone()
      clone.find("input").val('')
      clone.removeClass("template").appendTo($(templateContainer))
      return false
