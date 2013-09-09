(function($, document) {
  var Honegger;
  Honegger = function(element, options) {
    this.element = element;
    return this.options = options;
  };
  $.fn.honegger = function() {};
  return $.fn.honegger.defaults = {
    multipleSections: true,
    editable_selectors: '.section',
    toolbar_selector: '*[data-role="toolbar"]',
    toolbar_button_selector: '*[data-command]',
    toolbar_button_command: 'data-command',
    hotkeys: {
      'ctrl+b meta+b': 'bold',
      'ctrl+i meta+i': 'italic',
      'ctrl+u meta+u': 'underline',
      'ctrl+z meta+z': 'undo',
      'ctrl+y meta+y meta+shift+z': 'redo',
      'shift+tab': 'outdent',
      'tab': 'indent'
    }
  };
})(jQuery, document);

$.fn.honegger.toolbar = function() {};
