$(document).ready(function() {
	$.validator.addMethod("passwordCheck",function (value,element){
          return value==$("#user_password").val(); 

        }, 'Password does not match');
    $.validator.addMethod("emailCheck",function (value,element){
         var test_email = $("#user_email").val(); 
         var patt = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/;
         return value = patt.test(test_email); 
        }, 'Enter valid email');

  $('#new_user').validate({
	ignore: ".ignore, .select2-input, .select2-focusser",
    rules: {
      'user[full_name]': {
        required: true
      },
      'user[email]': {
        required: true,
        email: true,
        emailCheck: true
      },
      'user[mobile_number]': {
        number: true,
        required: true,
        minlength: 10,
        maxlength: 10        
      },
      'user[coupen_code]': {
        required: true,
      },
      'user[pincode]': {
        number: true,
        minlength: 6,
        maxlength: 6
       },
      'user[password]': {
        required: true,
        minlength: 6
      },
      'user[password_confirmation]': {
        required: true,
        passwordCheck: true
      },
      'user[schemes]': {
        required: true,
      },
      'user[slogan]': {
        maxlength: 100,
      },
      'user[landline_number]':{
      	number: true,
      	minlength: 6
      }
    },
    errorPlacement: function(error, element) {
      error.appendTo(element.parent().after());
      error.css('color', 'red');
    }
  });
});