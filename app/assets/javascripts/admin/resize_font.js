$(document).ready(function () {
    $(function() {
        while( $('.scheme-budget .number').width() > $('.scheme-budget .number-data').width() ) {
            $('.scheme-budget .number').css('font-size', (parseInt($('.scheme-budget .number').css('font-size')) - 1) + "px" );
        }
    });
});