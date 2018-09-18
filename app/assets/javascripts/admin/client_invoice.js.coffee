$(document).ready ->
  new ClientInvoiceWidget('.client-slcr-elmnt')

class @InvoiceCalculator
  calculatePointsRate: (points, rate)-> parseFloat(((points / 100) * rate).toFixed())
  calculateTax: (points_rate, tax)-> parseFloat(((points_rate / 100) * tax).toFixed())

class @ClientInvoiceWidget
  constructor: (selector) ->
    @$element = $("##{$(selector).attr('id')}")
    @$invoicePoints = $(".invoice-points")
    @$pointRate = $(".point-rate-labl")
    @$serviceTaxEl = $(".service-tax-labl")
    @$pointRateHead = $(".clt-points-rate-head")
    @$serviceTaxHead = $(".clt-service-tax-head")
    @$totalAmount = $(".total-amount-labl")
    @$rupeesLabel = $(".clnt-rupees-labl")
    @$convsnRate = $('#rp-conv-rate')
    @$convsGroup = $('.conversion-field-groups')
    if @$element.val()
      @$element = @$element.find(":selected") if @$element.find(":selected").val()
      @setConfig(@$element)
    $(document).on 'change', '#clnt-selector-for-invoice', (e) =>
      @setConfig($("##{$(e.target).attr('id')}").find(":selected"))
      @resetLabels()
      
    @$invoicePoints.on "change keyup paste mouseup input", (e) =>
      return false unless @$element.val() > 0
      @invoiceCalculator = new InvoiceCalculator()
      point_value = Math.round(@$invoicePoints.val() / @$pointsRatio)
      if $.isNumeric(point_value) && @$invoicePoints.val() > 0
        point_rate = @invoiceCalculator.calculatePointsRate(point_value, @$pucRate)
        tax_charge = @invoiceCalculator.calculateTax(point_rate, @$serviceTax)
        extra_charges = Math.round(point_rate + tax_charge)
        @$rupeesLabel.html(point_value)
        @$pointRate.html(point_rate)
        @$serviceTaxEl.html(tax_charge)
        @$totalAmount.html(parseFloat(point_value) + extra_charges)
      else
        @resetLabels()
        
  resetLabels: ->
    @$invoicePoints.val('')
    @$pointRate.html('')
    @$totalAmount.html('')
    @$rupeesLabel.html('')
    @$serviceTaxEl.html('')

  setConfig: (element) ->
    unless element.val()
      return @$convsGroup.hide()
    @$pucRate = element.data('puc-rate')
    @$serviceTax = element.data('service-tax')
    @$pointsRatio = element.data('points-ratio')
    @$convsnRate.html("1 Rupee = #{@$pointsRatio} Point(s)")
    @$pointRateHead.html("Points Uploading Charges (INR) (@ #{@$pucRate}% of Total Value)")
    @$serviceTaxHead.html("Service Tax @ #{@$serviceTax}% (INR)")
    @$convsGroup.show()