(function ($) {
  var element = $("#showcase-editor");
  var component_top, fix_toolbar_top, timeout, toolbar;
  toolbar = $('.text-editor-toolbar');
  component_top = 0;
  fix_toolbar_top = 60;
  timeout = null;
  element.on('scroll', function() {
    var component;
    component = element.find('.resource-text.edit-mode');
    toolbar.css('opacity', '0');
    if (timeout !== null) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(function() {
      if (component.length > 0) {
        component_top = component.find('.edit').offset().top - element.offset().top;
        toolbar.css({
          top: component_top + 30 < fix_toolbar_top ? fix_toolbar_top : component_top + 30
        });
        if (component_top < 0) {
          toolbar.css({
            top: fix_toolbar_top
          });
        }
        return toolbar.css('opacity', '1');
      }
    }, 300);
  });
})(jQuery);