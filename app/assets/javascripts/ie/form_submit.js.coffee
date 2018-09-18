$(document).ready ->
  new FormSubmit

class @FormSubmit
  constructor: () ->
    $('form button').click ->
      $(this).text($(this).attr("value"))