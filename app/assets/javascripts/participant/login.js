$(document).ready(function () {
    $('input.preventEdit').bind("cut copy paste", function (e) {
        e.preventDefault();
    });
});
