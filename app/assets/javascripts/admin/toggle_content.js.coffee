$(document).ready ->
  new ToggleContentWidget('.tc-widget')

class @ToggleContentWidget
  constructor: (slug)->
    $.each $(slug), ->
      selector = $(this)
      element = $(selector.data('target'))
      element.hide()
      if selector.is(':checked') || (selector.val() && selector.find('option:selected').length > 0)
        element.show()
      selector.on 'change', ->
        if selector.val() && (selector.is(':checked') || selector.find('option:selected').length > 0)
          element.show()
        else
          element.hide()
