$(document).ready ->
  @singleTierElement = $('.clnt-uic-noc')
  @$packTiersEdit = $('.clnt-pp-tiers-edit-form')
  $('.clnt-uic-noc').hide()
  $(document).on 'change', '.mt-tier-listing input', (e) =>
    selector = $("##{$(e.target).attr('id')}")
    if selector.val()
      @singleTierElement.hide()
    else
      @singleTierElement.show()

  $(document).on 'click', '#save-product-pack-config', (e) =>
    form = $('#product-pack-config')
    $.ajax
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize()
      dataType: "script"
      success: (response) ->
    false

  $(document).on 'click', '#clnt-pp-tiers-edit-ac', (e) =>
    $('#clnt-pp-tiers-prev-form').hide()
    $('#clnt-pp-tiers-edit-form').show()
    e.preventDefault()

  $(document).on 'click', '#clnt-pp-tiers-edit-cn', (e) =>
    $('#clnt-pp-tiers-prev-form').show()
    $('#clnt-pp-tiers-edit-form').hide()
    e.preventDefault()

  $(document).on 'click', '#sbt-gen-code-packs', (e) =>
    code_packs = $('#clnt-no-code-packs-gen')
    unless parseInt(code_packs.val()) > 0
      alert 'Please enter valid code packs'
      code_packs.focus()
      false
    e.preventDefault()
    code_form = $('#new_unique_item_code')
    code_form.append('<input name="unique_item_code[code_packs]" type="hidden" id="unique_item_code_codes_pack" value="'+code_packs.val()+'" />')
    code_form.submit()

  $(document).on 'change keyup paste mouseup input', '#clnt-no-code-packs-gen', (e) =>
    element = $(e.target)
    code_packs = element.val()
    codesUpdate = $('#clnt-total-codes-update')
    unless code_packs > 0 || $.isNumeric(code_packs)
      $(e.target).val('')
      codesUpdate.html('')
      return false
    codesUpdate.html(parseFloat(code_packs * element.data('codes-per-pack')))

  $(document).ajaxComplete (e) ->
    if $('.mt-tier-listing input:checked').val() <= 0
      @singleTierElement.show()
    else
      @singleTierElement.hide()

  save_code_button = $('#save-code-linkages-ac')
  save_code_button.hide()
  $('.noc-in').on 'change', (e) =>
    total_codes = parseFloat($('#total-unlinked-codes').val())
    noc = 0
    $('.noc-in').each ->
      noc += parseFloat(this.value) if this.value
    if noc > total_codes
      save_code_button.attr("disabled", true).hide()
      alert "Please ensure Number of Codes should not exceed Total Codes"
    else
      save_code_button.removeAttr("disabled").show()
      $('#unq-itm-cds-remaining-codes').text(total_codes-noc)
    e.preventDefault()