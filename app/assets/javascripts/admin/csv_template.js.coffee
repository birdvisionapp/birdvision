$(document).ready ->
  new LoadCsvTemplate()

class @LoadCsvTemplate
  constructor: ()->
    $("#scheme").change ->
      unless $(this).val()
        $(".template").hide()
        return
      $(".template-link").attr("href", $(this).find(":selected").attr('data-template'))
      $(".template").show()