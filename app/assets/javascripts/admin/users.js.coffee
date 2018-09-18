$(document).ready ->
  $("#ancestry_id").select2({width: '260px'})
  $("#participant_ids").select2({width: '260px'})
  $(".confirm-in-pa").on "click", ->
    checked = $('.user_checkbox:input[type="checkbox"]:checked').length
    if checked > 0
      rel_label = $(this).attr('rel')
      return confirm("Are you sure you want to Inactive " + checked + " "+ rel_label + "(s)?")
  $('.unlink-participant-rep').bind 'ajax:success', ->
    $(this).closest('tr').fadeOut()
    $('#tl-lnkd-ptps').text($('#tl-lnkd-ptps').text()-1)