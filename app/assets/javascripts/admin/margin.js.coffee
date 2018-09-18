$(document).ready ->
  new SupplierMarginWidget()
  new ClientMarginWidget()
  new BvcMarginWidget()

class @MarginCalculator
  calculateSupplierMargin: (channelPrice, mrp)->  (((mrp - channelPrice ) / mrp) * 100).toFixed(2)
  calculateBvcMargin: (bvcPrice, channelPrice)-> (((bvcPrice - channelPrice ) / channelPrice) * 100).toFixed(2)
  calculateClientMargin: (clientPrice, channelPrice)-> (((clientPrice - channelPrice ) / channelPrice) * 100).toFixed(2)

class @SupplierMarginWidget
  constructor: () ->
    @marginCalculator = new MarginCalculator()
    @defineSelectors()
    @assignEvents()

  defineSelectors: ->
    @mrpSelector = ".mrp"
    @channelPriceSelector = ".channel-price"
    @supplierMarginSelector = ".supplier-margin"
    @widgetSelector = ".supplier"

  assignEvents: ->
    $(@mrpSelector).keyup (event) => @updateMargin(event)
    $(@channelPriceSelector).keyup (event) => @updateMargin(event)

  updateMargin: (event) =>
    $supplier = $(event.target).closest(@widgetSelector)
    $supplier.find(@supplierMarginSelector).val(
      @marginCalculator.calculateSupplierMargin(
        $supplier.find(@channelPriceSelector).val(),
      $supplier.find(@mrpSelector).val()
      )
    )


class @ClientMarginWidget
  constructor: () ->
    @marginCalculator = new MarginCalculator()
    @$clientPrice = $(".client-price")
    @$channelPrice = $(".channel-price")
    @$clientMargin = $(".client-margin")
    @$clientPrice.keyup (e) => @$clientMargin.val(@marginCalculator.calculateClientMargin(@$clientPrice.val(), @$channelPrice.val()))

class @BvcMarginWidget
  constructor: () ->
    @marginCalculator = new MarginCalculator()
    @channelPriceSelector = ".channel-price"
    @preferredSupplierSelector = ".supplier .preferred:checkbox"
    @$bvcPrice = $(".bvc-price")
    @$bvcMargin = $(".bvc-margin")
    @bindEvents()

  bindEvents: =>
    @$bvcPrice.keyup (e) => @updateMargin(e)
    $(@channelPriceSelector).keyup (e) => @updateMargin(e)
    $(@preferredSupplierSelector).click (e) =>
      @unchekOthers(e)
      @updateMargin(e)

  unchekOthers: (event) =>
    $(@preferredSupplierSelector).prop('checked', false)
    $(event.target).prop('checked', true)

  updateMargin: (e) =>
    channelPrice = $(".supplier .preferred:checked").closest(".supplier").find(".channel-price").val()
    @$bvcMargin.val(@marginCalculator.calculateBvcMargin(@$bvcPrice.val(), channelPrice))


# todo - kd - make methods private
# creating class with @ will expose them to global scope.
# to manually expose use: window.MarginCalculator = MarginCalculator


