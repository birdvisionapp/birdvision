//= require application
//= require ckeditor/config
//= require ckeditor/init
//= require bootstrap-dropdown.js
//= require bootstrap-collapse.js
//= require_tree ./admin
//= require common
//= require admin/nested_form
//= require select2
//= require jquery.minicolors
//= require client_managers_widgets
//= require highcharts.js
//= require admin/templates
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require admin/targeted_offer_managers
//= require user_registrations

$(document).ready(function () {
	if ($('select[name="reward_item[client_id]"]').val() == 411) {
		$('#al-specific').show();
	}
	$('select[name="reward_item[client_id]"]').change(function() {
    	var client_id = $(this).val();
    	if (client_id == 411) {
    		$('#al-specific').show();
    	} else {
    		$('#al-specific').hide();
    	}
	});
	
    var check1 = $('#ord-approval').is(':checked');
    if (check1) {
        $('#ord-approval-lt').show();
    }
    $('#ord-approval').change(function () {
        var name = $(this).val();
        var check = $(this).is(':checked');
        if (check){
            $('#ord-approval-lt').show();
        } else {
            $('#ord-approval-lt').find('.input-mini').val(0);
            $('#ord-approval-lt').hide();
        }
    });
    $('.has_tooltip').tooltip();
    $('.go_to_page a').click(function () {
        var page = $(this).siblings('input'),
        max = $(this).attr("data-max");
        if (page.val() > max) {
            page.val(max);
        }
        document.location.search = $(".user_search").add(page).serialize();
        return false;
    });
    var updateMspSelection = function() {
        $('#client_msp_id').prop("disabled", !$('#enable_move_client_to_msp').prop("checked"));
    };
    
    $('#enable_move_client_to_msp').change(updateMspSelection);

    $("#refresh-page").click(function(){
        location.reload();
    });

    $('.created-at-gteq').click(function(){
        $('.created-at-date-gteq').val('');
        $('.created-at-date-lteq').val('');
    });
    
    $(".created-at-date-gteq").focusin(function() {
        $(".created-at-gteq").val("Select Time Period");
    });
});

