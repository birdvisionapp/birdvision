$(document).ready(function() {
    validateTransc();
});

function validateTransc()
{
	$('#id-transc').validate({
		rules:{
			'to_transaction[address_name]':{
				required: true
			}, 
			'to_transaction[address_body]':{
				required: true
			},
			'to_transaction[address_city]':{
				required: true
			},
			'to_transaction[address_state]':{
				required: true
			}, 
			'to_transaction[address_zip_code]':{
				required: true,
				number: true,
				minlength: 6,
				maxlength: 6
				
			},
			'to_transaction[address_phone]':{
				required: true,
				number: true,
				minlength: 10,
				maxlength: 10

			}
		},
		messages:{
			'to_transaction[address_name]':{
				required: '*Name field is required'
			}, 
			'to_transaction[address_body]': {
				required: '*Address field is required'
			},
			'to_transaction[address_city]':{
				required: '*City field is required'
			}, 
			'to_transaction[address_state]': {
				required: '*State field is required'
			},
			'to_transaction[address_zip_code]':{
				required: '*Pin code is required',
				number: '*Only number allowed(0-9)',
				minlength: '*Minimum 6 digit number allowed',
				maxlength: '*Maximun 6 digit number allowed'
			}, 
			'to_transaction[address_phone]':{
				required: '*Mobile number field is required (10 digit)',
				number: '*Only number allowed(0-9)',
				minlength: '*Minimum 10 digit number allowed',
				maxlength: '*Maximun 10 digit number allowed'
			}

		},
        errorElement: 'div',
        errorPlacement: function(error, element) {
            element.after(error);
        }
	});
}