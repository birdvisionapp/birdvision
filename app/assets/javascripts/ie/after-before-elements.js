$(document).ready(function(){
    $(".btn-continue-shopping").prepend("<div class='btn-continue-shopping-cart'></div>");
    $("#clientItemCarousel").append("<div class='carousel-featured-tag'></div>");
    $(".catalogs").find(".header").find(".view-all").after("<div class='view-all-after'></div>");
    $("#category-filter").find(".collapsible").find(".global-category-header").find("span").append("<div class='category-header-after'></div>");
    $(".shopping-cart-icon").find(".items-count").append("<div class='items-count-after'></div>");
    $(".zoomPad").append("<div class='zoomPad-after'>Mouse over to zoom</div>");
    $(".mandatory-field").append("<div class='mandatory-field-star'>*</div>");
    $(".tabs li").prepend("<div class='active-after'></div>");
    $("#category-filter").find(".category-list>li").hover(function(){
        $(this).append("<div class='li-hover-after'></div>");
    },
    function(){
        $(".li-hover-after", this).remove();
    });
});