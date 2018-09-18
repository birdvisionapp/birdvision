$(document).ready(function() {
    templateSelection();
    validateCampaignForm();
    selectAllMedium();
    formTemplateValidate();
    selectAllCategory();
    validateRelationshipMatrixForm();
    incentiveRender();
    datepicks();
    selectAllGeography();
    datePickerValidation();
});

$(document).on('ready readyAgain', function() {
    validateOfferForms();
    validateLifeEventForm();
    hideMessages();
    hideDivSelection();
    select_all();
    limitProductSelection();
    select_all_product();
    incentiveRender();
    datepicks();
    selectAllGeography();
    datePickerValidation();
});

function toConfig() {
    $.ajax({
        type: 'get',
        url: '/admin/to_configuration/to_config'
    });
}

function collectionSelected(e) {
    var check_msp = $('#client_msp_id_selected :selected').val();
    if (check_msp != "") {
        var msp_id = check_msp;
    } else {
        var msp_id = 0;
    }
    $.ajax({
        url: '/admin/to_configuration/select_client',
        data: {
            msp_id: msp_id
        },
        type: "get",
        success: function(data) {
            if (data.length == 0) {
                $('#client_client_id_dropdown').empty();
                var div_data = "<option value=''> No Client </option>";
                $(div_data).appendTo('#client_client_id_dropdown');
            } else {
                $('#client_client_id_dropdown').empty();
                $.each(data, function(index, value) {
                    $('#client_client_id_dropdown').empty();
                    $.each(data, function(i, obj) {
                        var div_data = "<option value=" + obj.id + ">" + obj.client_name + "</option>";
                        $(div_data).appendTo('#client_client_id_dropdown');
                    });
                });
            }
        },
        error: function(data) {
            $('#client_client_id_dropdown').empty();
        }
    });
}

function datePickerValidation() {
    $('#dateFrom').datepicker({
        startDate: "Biginning of time",
        autoclose: true,
        format: 'dd-mm-yyyy'
    }).on('changeDate', function(selected) {
        startDate = new Date(selected.date.valueOf());
        startDate.setDate(startDate.getDate(new Date(selected.date.valueOf())));
        $('#dateTo').datepicker('setStartDate', startDate);
    });
    $('#dateTo').datepicker({
        startDate: "Biginning of time",
        autoclose: true,
        format: 'dd-mm-yyyy'
    }).on('changeDate', function(selected) {
        FromEndDate = new Date(selected.date.valueOf());
        FromEndDate.setDate(FromEndDate.getDate(new Date(selected.date.valueOf())));
        $('#dateFrom').datepicker('setEndDate', FromEndDate);
    });
}

function templateSelection()
{
    $('#targeted_offer_type_id').change(function(event) {
        var name = $("#targeted_offer_type_id option:selected").text();
        var to_name = name.replace(/ /g, "_").toLowerCase();
        var url = '/admin/to_configuration/render_required_templates';
        var client_id = $("#hidden_client").val();
        $.ajax({
            url: url,
            data: {
                client_id: client_id,
                name: name
            },
            success: function(data) {
                $(document).trigger('readyAgain');
            },
            error: function(data) {
            }
        });
    });
}

function productSelection() {
    $('.check').click(function(event) {
        var schemes = new Array();
        var client_id = $("#hidden_client").val();
        $("input:checked").each(function() {
            schemes.push($(this).val());
        });
        $.ajax({
            url: '/admin/to_configuration/product',
            data: {
                schemes: schemes,
                client_id: client_id
            },
            success: function(data) {
                select_all_product();
                limitProductSelection();
            },
            error: function(data) {

            }
        });
    });
}

function select_all() {
    $('#id_scheme').click(function() {
        $('#scheme1 div.error').hide();
    });

    $('#id_scheme').click(function(event) {
        if (this.checked) {
            $('.check').each(function() {
                this.checked = true;
            });
        } else {
            $('.check').each(function() {
                this.checked = false;
            });
        }
    });

    $('.check').click(function() {
        if ($('.check').length == $('.check:checked').length) {
            $('#id_scheme').attr("checked", "checked");
        } else {
            $('#id_scheme').removeAttr("checked");
        }
    });
    productSelection();
}

function select_all_product() {
    $('#id_product').click(function() {
        $('#product div.error').hide();
    });

    $('#id_product').click(function(event) {
        if (this.checked) {
            $('.check1').each(function() {
                this.checked = true;
                $("input[name='select_product[]']:not(:checked)").removeAttr('disabled');
            });
        } else {
            $('.check1').each(function() {
                this.checked = false;
                var len = $("input[name='select_product[]']:checked").length;
                if (len >= 3) 
                {
                    $("input[name='select_product[]']:checked").prop('checked', false);
                }
            });
        }
    });
    
    $('.check1').click(function() {
        if ($('.check1').length == $('.check1:checked').length) {
            $('#id_product').attr("checked", "checked");
        } else {
            $('#id_product').removeAttr("checked");
            var len = $("input[name='select_product[]']:checked").length;
            if (len >= 4) 
            {
                $("input[name='select_product[]']:checked").prop('checked', false);
            }
        }
    });
    limitProductSelection();
}

function selectAllGeography() {
    $('#telecom_circle_id').click(function(event) {
        if (this.checked) {
            $('.check_geography').each(function() {
                this.checked = true;
            });
        } else {
            $('.check_geography').each(function() {
                this.checked = false;
            });
        }
    });

    $('.check_geography').click(function() {
        if ($('.check_geography').length == $('.check_geography:checked').length) {
            $('#telecom_circle_id').attr("checked", "checked");
        } else {
            $('#telecom_circle_id').removeAttr("checked");
        }
    });
}

function selectAllMedium() {
    $('#select_all').click(function(event) {
        if (this.checked) {
            $('.medium-check').each(function() {
                this.checked = true;
            });
        } else {
            $('.medium-check').each(function() {
                this.checked = false;
            });
        }
    });

    $('.medium-check').click(function() {
        if ($('.medium-check').length == $('.medium-check:checked').length) {
            $('#select_all').attr("checked", "checked");
        } else {
            $('#select_all').removeAttr("checked");
        }
    });
}

function selectAllCategory() {
    $('#all_category').click(function(event) {
        if (this.checked) {
            $('.check_category').each(function() {
                this.checked = true;
            });
        } else {
            $('.check_category').each(function() {
                this.checked = false;
            });
        }
    });
    $('.check_category').click(function() {
        if ($('.check_category').length == $('.check_category:checked').length) {
            $('#all_category').attr("checked", "checked");
        } else {
            $('#all_category').removeAttr("checked");
        }
    });
}

function hideMessages() {
    $('#offer_manager_incentive_type_gift').click(function() {
        $("#offer_manager_incentive_percentage-error").hide();
        $("#offer_manager_gift_catlog_id").removeClass("error");
    });
    $('#offer_manager_incentive_type_percentage, #offer_manager_incentive_type_gift, #offer_manager_incentive_type_gift_client-gift, #offer_manager_incentive_type_gift_catlog-gift').click(function() {
        $("#id-set-incentive-type div.error").hide();
    });
    $('#id_scheme').click(function() {
        $("#id-set-scheme div.error").hide();
    });
    $('#offer_manager_incentive_type_gift_catlog-gift, #offer_manager_incentive_type_gift_client-gift').click(function() {
        $("#id-set-incentive-type div.error").hide();
    });
    $('#all_category').click(function() {
        $("#id-set-participant div.error").hide();
    });
    $('#campaingn_manager_age_range_all-range').click(function() {
        $("#id-set-age div.error").hide();
    });
    $('#campaingn_manager_telecom_circle_id_all-telecom-circle').click(function() {
        $('#id-set-geography div.error').hide();
    });
    $('#datepicker').click(function() {
        $('#id-set-datepicker div.error').hide();
    });
    $('#id_product').click(function(){
    	$("#id-set-product div.error").hide();
    });
    $('#offer_manager_performace_count_scheme_start, #offer_manager_performace_count_to_start, #offer_manager_performace_count_custom_date').click(function(){
    	$("#id-set-performance div.error").hide();
    });
}


function validateOfferForms() {
    $('#purchase_freq_form').validate({
        rules: {
            'offer_manager[targeted_offer_type_id]': {
                required: true
            },
            'select_template': {
                required: true
            },
            'schemes[]': {
                required: true
            },
            'offer_manager[first_action]': {
                required: true
            },
            'offer_manager[incentive_type]': {
                required: true,
            },
            'offer_manager[incentive_percentage]': {
                required: true,
                number: true
            },
            'offer_manager[gift_name]': {
                required: true,
            },
            'offer_manager[gift_catlog_id]': {
                required: true,
            },
            'offer_manager_gift_catlog_id': {
                required: true
            },
            'select_product[]': {
                required: true
            },
            'offer_manager[client_purchase_frequency]': {
                required: true,
                number: true
            },
            'offer_manager[performance_from]': {
                required: true
            },
            'offer_manager[performance_to]': {
                required: true
            },
            'offer_manager[festival_type]': {
                required: true
            }
        },
        messages: {
            'offer_manager[targeted_offer_type_id]': {
                required: "Please select Targeted Offer Type"
            },
            'select_template': {
                required: "Please select Template"
            },
            'schemes[]': {
                required: "Please select Scheme"
            },
            'offer_manager[first_action]': {
                required: "Please select Insentive type"
            },
            'offer_manager[incentive_type]': {
                required: "Please select incentive type"
            },
            'offer_manager[incentive_percentage]': {
                required: "Please enter percentage for extra points"
            },
            'offer_manager[gift_name]': {
                required: "Please enter gift name"
            },
            'select_template': {
                required: "Please select template"
            },
            'offer_manager[gift_catlog_id]': {
                required: 'Please select gift from catalog'
            },
            'select_product[]': {
                required: 'Please select Products'
            },
            'offer_manager[client_purchase_frequency]': {
                required: 'Please select client purchase frequency'
            },
            'offer_manager[performance_from]': {
                required: 'Please select start date'
            },
            'offer_manager[performance_to]': {
                required: 'Please select end date'
            },
            'offer_manager[festival_type]': {
                required: 'Please fill festival details'
            }
        },
        errorElement: 'div',
        errorPlacement: function(error, element) {
            element.parent().before(error);
        }
    });
}

function validateRelationshipMatrixForm() {
    $('#relationship_matrix_form').validate({
        rules: {
            'select_template': {
                required: true
            },
            'offer_manager[client_purchase_frequency]': {
                required: true
            },
            'schemes[]': {
                required: true
            }
        },
        messages: {
            'select_template': {
                required: 'Please select Template'
            },
            'offer_manager[client_purchase_frequency]': {
                required: 'Please select Earning Points'
            },
            'schemes[]': {
                required: 'Please select schemes'
            }
        }
    });
}

function validateLifeEventForm() {
    $('#major_life_event_form').validate({
        rules: {
            'select_template': {
                required: true
            },
            'schemes[]': {
                required: true
            },
            'offer_manager[client_life_event_threshold]': {
                required: true
            },
            'offer_manager[gift_name]': {
                required: true,
            },
            'offer_manager[gift_catlog_id]': {
                required: true,
            },
            'offer_manager_gift_catlog_id': {
                required: true
            },
            'offer_manager[client_purchase_frequency]': {
                required: true
            },
            'offer_manager[performance_from]':{
            	required: true
            }, 
            'offer_manager[performance_to]': {
            	required: true
            }
        },
        messages: {
            'offer_manager[targeted_offer_type_id]': {
                required: "Please select Targeted Offer Type"
            },
            'select_template': {
                required: "Please select Template"
            },
            'schemes[]': {
                required: "Please select Scheme"
            },
            'offer_manager[client_life_event_threshold]': {
                required: "Enter threashold limit"
            },
            'offer_manager[gift_name]': {
                required: "Please enter gift name"
            },
            'offer_manager[gift_catlog_id]': {
                required: 'Please select gift from catalog'
            },
            'offer_manager[client_purchase_frequency]': {
                required: 'Please select client purchase frequency'
            },
            'offer_manager[performance_from]':{
            	required: 'Please select Start date'
            }, 
            'offer_manager[performance_to]': {
            	required: 'Please select End date'
            }
        },
        errorElement: 'div',
        errorPlacement: function(error, element) {
            element.parent().before(error);
        }
    });
}

function validateCampaignForm() {
    $('#campaign_form').validate({
        rules: {
            'selective_category_ids[]': {
                required: true
            },
            'campaingn_manager[age_from]': {
                required: true,
                min: 1
            },
            'campaingn_manager[age_to]': {
                required: true,
                min: 1
            },
            'telecom_circle_select[]': {
                required: true
            },
            'campaingn_manager[start_date]': {
                required: true
            },
            'campaingn_manager[end_date]': {
                required: true
            }

        },
        messages: {
            'selective_category_ids[]': {
                required: "You must check at least one category"
            },
            'campaingn_manager[age_from]': {
                required: "Please select Custom Age range From"
            },
            'campaingn_manager[age_to]': {
                required: "Please select Custom Age range To"
            },
            'telecom_circle_select[]': {
                required: "Please select Telecom Circle"
            },
            'campaingn_manager[start_date]': {
                required: "Please select Start Date"
            },
            'campaingn_manager[end_date]': {
                required: "Please select End Date"
            }
        },
        errorElement: 'div',
        errorPlacement: function(error, element) {
            element.parent().before(error);
        }
    });
}

function formTemplateValidate() {
    $('#formTemplate').validate({
        rules: {
            'template[name]': {
                required: true
            },
            'template[template_content]': {
                required: true
            },
            'template[targeted_offer_type_id]': {
                required: true
            }
        },
        messages: {
            'template[name]': {
                required: 'Please enter Template name'
            },
            'template[template_content]': {
                required: 'Please enter Template content'
            },
            'template[targeted_offer_type_id]': {
                required: 'Please select Template Basis'
            }
        },
        errorElement: 'div',
        errorPlacement: function(error, element) {
            element.before(error);
        }
    });
}

function hideDivSelection() {
    $("#offer_manager_incentive_type_percentage").click(function() {
        document.getElementById("gift_div").disabled = true;
        var nodes = document.getElementById("gift_div").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
        var nodes = document.getElementById("gift_div1").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
        var nodes = document.getElementById("points_div").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
    });

    $("#offer_manager_incentive_type_gift").click(function() {
        document.getElementById("gift_div").disabled = true;
        var nodes = document.getElementById("gift_div").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
        $('#offer_manager_incentive_type_gift_client-gift').attr("checked", "checked");

        var nodes = document.getElementById("points_div").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
        $("input[name='offer_manager[incentive_type_gift]']:not(:checked)").removeAttr('disabled');
    });
    
    $("#offer_manager_incentive_type_gift_client-gift").click(function(){
    	$("input[name='offer_manager[incentive_type_gift]']:not(:checked)").removeAttr('disabled');
    });

    $("#offer_manager_incentive_type_gift_client-gift").click(function() {
        var nodes = document.getElementById("select_gift_name").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
        var nodes = document.getElementById("enter_gift_name").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
    });

    $("#offer_manager_incentive_type_gift_catlog-gift").click(function() {
        var nodes = document.getElementById("select_gift_name").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
        var nodes = document.getElementById("enter_gift_name").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
    });


    $("#campaingn_manager_age_range_all-range").click(function() {
        var nodes = document.getElementById("custom_range").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
    });
    $("#campaingn_manager_age_range_custom-age-range").click(function() {
        var nodes = document.getElementById("custom_range").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
    });

    $("#campaingn_manager_telecom_circle_id_all-telecom-circle").click(function() {
        var nodes = document.getElementById("selective_telecom_circle").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
    });

    $("#campaingn_manager_telecom_circle_id_selected-telecom-circle").click(function() {
        var nodes = document.getElementById("selective_telecom_circle").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
    });

    $('#offer_manager_performace_count_custom_date').click(function() {
        var nodes = document.getElementById("date_valid").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = false;
        }
    });

    $('#offer_manager_performace_count_scheme_start').click(function() {
        var nodes = document.getElementById("date_valid").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
    });

    $('#offer_manager_performace_count_to_start').click(function() {
        var nodes = document.getElementById("date_valid").getElementsByTagName('*');
        for (var i = 0; i < nodes.length; i++) {
            nodes[i].disabled = true;
        }
    });
}

function limitProductSelection() {
    $('.check1').click(function() {
        var len = $("input[name='select_product[]']:checked").length;
        if (len == 3) {
            $("input[name='select_product[]']:not(:checked)").prop("disabled", this.checked);
        }
        else
        {
            $("input[name='select_product[]']:not(:checked)").removeAttr('disabled');
        }
    });
}

function incentiveRender()
{
    $("input:radio[name=select_template]").click(function() {
    var template_id = $(this).val();
    var client_id = $("#hidden_client").val();
    $.ajax({
        url: '/admin/to_configuration/gift',
        data: {
                template_id : template_id,
                client_id : client_id
            },
            success: function(data) {
                $(document).trigger('readyAgain');
            },
            error: function(data) {

            }
        });
    });
}

function datepicks()
{
	$('#start, #end').datepicker({
		autoclose: true,
		format: 'dd-mm-yyyy'
	});
}
