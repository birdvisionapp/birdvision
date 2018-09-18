$(document).ready(function () {
    
  $("#template_content").keyup(function(event) {
  	if (event.keyCode == 13) {
  		event.preventDefault();
        return false;
    }
    var chars = $("#template_content").val().length;
    var tex=140-chars;
    if (chars > 140){
    	alert("Character Length Exiding");
    	
    }
    document.getElementById('count').innerHTML = tex;
    
  });  
});

$(document).ready(function(){
	
	$('#template').validate({
		debug: true,
		rules: {
			"template[name]":{ required: true },
			"template[template_content]": {	required: true }
		},
		
		messages: {
			"template[name]": "Please enter Template Name",
			"template[template_content]": "Please enter Template Content"
		}
	});
});