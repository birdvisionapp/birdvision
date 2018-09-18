$(document).ready ->
  new FilterWidget()


class @FilterWidget
  constructor: ()->
    $("#filters-title").click (e) =>
      e.preventDefault()
      $("#filters-content").toggleClass("hide")
      $("#filters-opener").toggleClass("opened")
      $("#filters-container").toggleClass("whole")