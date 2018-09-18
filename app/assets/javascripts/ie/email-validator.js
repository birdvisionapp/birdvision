$(document).ready(function(){
    var ValidateEmail = function(mail) {
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,})+$/.test(mail)) {
            return (true)
        }
        return (false)
    }

    $(".contact-us .form-horizontal").submit(function(event){
        var email = $(".contact-us #contact_email").val();
        if(email && !ValidateEmail(email)) {
            event.preventDefault();
            alert("Please Enter Valid Email Address");
            return false;
        }
        return true;
    })
})