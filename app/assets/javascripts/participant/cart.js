$(document).ready(function () {
    $(".save-quantity").tooltip({placement:'right',title:'Click Save to Update'});


   $(".change-quantity").click(function(e){
       e.preventDefault();
       $(this).hide();
       $(this).siblings(".quantity").hide();
       var changeQuantityForm = $(this).siblings(".change-quantity-form");
       changeQuantityForm.removeClass("hide");
       changeQuantityForm.find(".item-quantity").focus();
   });
});