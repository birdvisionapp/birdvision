(function($) {
    $.fn.ellipsis = function(options) {
        var defaults = {
            row : 1,
            char : '...'
        };

        options = $.extend(defaults, options);

        this.each(function() {

            var $this = $(this);
            var text = $this.text();
            $this.text('a');
            var rowHeight = $this.height();
            $this.text('');
            var rowCount = 1;
            var flag = false;
            var height = 0;

            for (var i = 0; i < text.length; i++) {

                var s = text.substring(i, i + 1);
                $this.text($this.text() + s);
                height = $this.height();

                if (height !== 0 && height !== rowHeight) {
                    rowHeight = height;
                    rowCount++;

                    if (rowCount > options.row) {
                        flag = true;
                        break;
                    }
                }
            }

            if (flag) {
                text = $this.text();
                while (true) {
                    text = text.substring(0, text.length - 20);
                    $this.text(text + options.char);
                    height = $this.height();
                    if (height < rowHeight) {
                        break;
                    }
                }
            }
        });

        return this;
    };
})(jQuery);

