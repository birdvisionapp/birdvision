$(document).ready ->
  new SelectAllWidget(".select-all", ".selectable")

class @SelectAllWidget
  constructor: (selector, selectable)->
    $(selector).change ->
      $(selectable).prop('checked', $(this).prop('checked'))

