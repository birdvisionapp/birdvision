$(document).ready ->
  new ViewLoader('.rvl-widget')

class @ViewLoader
  constructor: (slug)->
    $.each $(slug), (i, el) =>
      selector = $("##{$(el).attr('id')}")
      element = $(selector.data('target'))
      return false unless selector.length > 0 || element.length > 0
      element.hide()
      if selector.find('option').length <= 2
        selector.val(selector.find('option').eq(1).val())
      else
        if selector.val()
          @loadContent(selector, element)
      $(document).on 'change', selector, (e) =>
        selector = $("##{$(e.target).attr('id')}")
        element = $(selector.data('target'))
        @loadContent(selector, element)

  loadContent: (selector, container) ->
    selector = selector.find(":selected") unless selector.is(':checked')
    empty_container = container.html('').hide()
    return empty_container unless selector.val()
    $.ajax
      url: selector.data('template')
      type: 'GET'
      dataType: 'html'
      beforeSend: () ->
        container.html('Loading...').show()
      success: (data, textStatus, jqXHR) ->
        unless data == ''
          container.html(data).show()
        else
          empty_container    