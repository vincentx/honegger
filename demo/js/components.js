var Demo = {
    TemplateComponents: {
        'textbox': {
            editor: function (template, config) {
                var editor = $(template);
                editor.find('.component-header').html('Text');
                editor.find('.component-content').html($('<div class=\"form-horizontal\">\n  <div class=\"form-group\">\n    <label class=\"col-xs-4 control-label\">Minimal Word Count<\/label>\n    <div class=\"col-xs-3\"><input type=\"number\" data-component-config-key=\"min-word-count\" class=\"form-control\" min=\"0\" value=\"30\"><\/div>\n  <\/div>\n<\/div>\n'));
                return editor;
            },
            dataTemplate: {"content": ""},
            control: function (prefix, value) {
                var control = $('<div>\n  <textarea class=\"form-control\" data-template-field=\"content\"><\/textarea>\n<div>\n');
                if (value != undefined) {
                    (function () {
                        control.attr('data-component-id', component_id);
                        $('.form-control', control).attr('name', function () {
                            return prefix + "[" + $(this).attr('data-template-field') + "]";
                        });
                        $('.form-control', control).val(value.content);
                        $('.form-control', control).wrap(function () {
                            return '<div lt-field="' + $(this).attr('name') + '"></div>';
                        });
                        $('.form-control', control).after(function () {
                            return '<p class="help-block" lt-field-error="' + $(this).attr('name') + '"></p>';
                        });
                        if (!enable) {
                            $('.form-control', control).attr('disabled', true)
                        }
                    })();
                }
                return control;
            }
        }
    }
};