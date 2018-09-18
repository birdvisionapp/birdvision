$(document).ready(function () {

    $('#search_keyword').keyup(function (e) {
        var keywords = $.trim(this.value);
        var $submit_button = $('#searchForm input[type="submit"]');

        if (keywords) {
            $submit_button.removeAttr("disabled");
        } else {
            $submit_button.attr('disabled','true');
        }
    });
});
