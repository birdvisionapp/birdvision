if (typeof CKEDITOR != 'undefined') {
    CKEDITOR.editorConfig = function (config) {
        config.removeDialogTabs = 'link:advanced;table:advanced;link:target';
        config.removePlugins = 'elementspath';
        config.toolbar = 'Easy';
        config.format_tags = 'h3;p;pre';
        config.toolbar_Easy = [
            ["Format"],
            ["Bold", "Italic", "Underline", "Strike"],
            ["NumberedList", "BulletedList", "Outdent", "Indent", "Link", "Unlink", "Table", "HorizontalRule"]
        ];
        config.startupOutlineBlocks = false;
        config.pasteFromWordRemoveFontStyles = true;
        config.pasteFromWordRemoveStyles = true;
        config.pasteFromWordNumberedHeadingToList = true;
    };

    CKEDITOR.on('dialogDefinition', function (ev) {
        var dialogName = ev.data.name;
        var dialogDefinition = ev.data.definition;
        if (dialogName == 'link') {
            dialogDefinition.onShow = function () {
                var dialog = CKEDITOR.dialog.getCurrent();
                elem = dialog.getContentElement('info', 'anchorOptions');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'emailOptions');
                elem.getElement().hide();
                var elem = dialog.getContentElement('info', 'linkType');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'protocol');
                elem.getElement().hide();
            };
        }
        if (dialogName == 'table') {
            dialogDefinition.onShow = function () {
                var dialog = CKEDITOR.dialog.getCurrent();
                elem = dialog.getContentElement('info', 'txtBorder');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtWidth');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtHeight');
                elem.getElement().hide();
                var elem = dialog.getContentElement('info', 'cmbAlign');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtCellSpace');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtCellPad');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtCaption');
                elem.getElement().hide();
                elem = dialog.getContentElement('info', 'txtSummary');
                elem.getElement().hide();
            };
        }
    });
}
