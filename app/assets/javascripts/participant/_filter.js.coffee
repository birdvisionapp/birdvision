$(document).ready ->
  new FilterByPointsWidget

#TODO specs???

class @FilterByPointsWidget
  constructor: () ->
    sliderValueFor = (attr_name) ->
      parseInt($('#points_slider').attr(attr_name), 10)

    min = sliderValueFor("data-min")
    max = sliderValueFor("data-max")
    selectedMin = sliderValueFor("data-selected-min")
    selectedMax = sliderValueFor("data-selected-max")

    selectedMinElement  = $("#search_point_range_min")
    selectedMaxElement  = $("#search_point_range_max")

    stepSize = Math.pow(10, Math.ceil(Math.log(parseInt((max - min), 10)) / Math.LN10) - 2);

    $("#points_slider").slider({
      range: true,
      min: min,
      max: max,
      step: stepSize,
      values: [ selectedMin, selectedMax],
      slide: (event, ui) ->
        selectedMinElement.val(ui.values[0]);
        selectedMaxElement.val(ui.values[1]);
      }
    )

