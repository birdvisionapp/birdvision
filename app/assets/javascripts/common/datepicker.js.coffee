$(document).ready ->
  $(".datepicker").datepicker({format: "dd-mm-yyyy", autoclose: true})

  $(".datepicker.input-small").each ->
    date = new Date($(this).val())
    format = (value) ->
      return "0" + value  if value < 10
      value

    unless isNaN(date)
      newDate = format(date.getDate()) + "-" + format((date.getMonth() + 1)) + "-" + date.getFullYear()
      $(this).val(newDate).datepicker('update')