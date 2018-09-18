// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require bootstrap-filestyle-0.1.0
//= require bootstrap-datepicker
//= require bootstrap-transition
//= require bootstrap-carousel
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-tab
//= require lib/jquery-ui-only-slider.min.js
//= require underscore
//= require_tree ./participant
//= require common
//= require user_registrations

$(document).ready(function(){
    var options = {
        zoomType: 'standard',
        lens:true,
        preloadImages: true,
        preloadText: "Loading...",
        alwaysOn:false,
        zoomWidth: 400,
        zoomHeight: 400,
        xOffset:20,
        yOffset:0,
        position:'right',
        title: false
    };
    $('.image_zoom').jqzoom(options);

    var newimgsrc = $('#hidden-bg-img').data('url');
	if(newimgsrc == null)
	{   
		 $('#user-wrapper').css('background-image', 'url(/assets/giftPic.jpg)');
		 $('.login-page-body').css('background-image', 'url(/assets/giftPic.jpg)');
	}
	else if(newimgsrc.indexOf("missing.png") != -1)
	{   
		 $('#user-wrapper').css('background-image', 'url(/assets/giftPic.jpg)');
		 $('.login-page-body').css('background-image', 'url(/assets/giftPic.jpg)');
	}
	else
	{
		 $('.logo').addClass("bridgeston");
         $('body').css("background-image", "url("+newimgsrc+")") ;
	}
});


$(document).ready(function() {
	var getview = getCookie("retainview");

	if(getview == "list")
	{
		setListView();
	}
	else if (getview == "picture")
	{
		setPictureView();
	}
	
    $('#list').click(function(event) {
    	$('#retain-view').val("list");
    	$('.items-grid.thumbnails').css("padding-left", "");
    	$('.client-item.thumbnail.span4').addClass('span3');
        $('.client-item.thumbnail.span4').removeClass('span4');
        setListView();
        createCookie('list');
    });
    $('#grid').click(function(event) {
        event.preventDefault();
        $('.client-item').css("width", "");
        $('.image-container').addClass('item-image-container');
        $('.image-container').removeClass('image-container');
        $('.do-nothing-car').addClass('image-container');
        $('.do-nothing-car').removeClass('item-image-container');
        $('.item-content').show();
        $('.do-nothing').hide();
        $('.large-grid').hide();
        $('#picture').show();
        $('#grid').hide();
        $('.large-grid').hide();
        createCookie('grid');
    });
    $('#picture').click(function(event) {
    	setPictureView();
        event.preventDefault();
        createCookie('picture');
    });
});

$( document ).ready(function() {
	if($(".client-item.thumbnail.span4").length > 0) {
		$('.thumbnail').click(function(e){
			e.preventDefault();
   			$(this).find('.caption').slideDown(250);
		});
	}
    $('.thumbnail').hover(
        function(){
            $(this).find('.caption').slideDown(250); //.fadeIn(250)
        },
        function(){
            $(this).find('.caption').slideUp(250); //.fadeOut(205)
        }
    ); 
});

function createCookie(value) {
	var expires = "";
	var name = "retainview";
	document.cookie = name+"="+value+"; path=/";
	document.cookie = name+"="+value+"; path=/search";
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function setListView() {
	event.preventDefault();
    $('.client-item').css("width", "100%") ;
    $('.item-image-container').addClass('image-container');
    $('.item-image-container').removeClass('item-image-container');
    $('.item-content').hide();
    $('.do-nothing').show();
    $('.large-grid').hide();
    $('#grid').show();
    $('#list').hide();
    $('#picture').hide();
    $('.large-grid').hide();
}

function setPictureView() {
	$('.client-item.thumbnail.span3').addClass('span4');
	$('.client-item.thumbnail.span3').removeClass('span3');
	$('.large-grid').show();
    $('#list').show();
    $('#picture').hide();
    $('#grid').hide();
    $('.item-content').hide();
    $('.items-grid.thumbnails').css("padding-left", "38px");
}