(function($, document, window) {
  var Honegger;
  Honegger = function(element, options) {
    var currentRange;
    this.element = $(element);
    this.options = options;
    this.element.data('honegger', this);
    this.element.addClass('has-honegger');
    currentRange = function() {
      var range, selection;
      selection = window.getSelection();
      if ((selection.getRangeAt != null) && selection.rangeCount) {
        range = selection.getRangeAt(0);
        if ($.inArray(element, $(range.startContainer).parents()) !== -1) {
          return range;
        }
      }
    };
    return this.execCommand = function(command) {
      if (currentRange() != null) {
        return document.execCommand(command);
      }
    };
  };
  $.fn.honegger = function(options) {
    var parameters;
    parameters = $.makeArray(arguments).slice(1);
    return this.each(function() {
      var instance;
      instance = $.data(this, 'honegger');
      if (!instance) {
        return new Honegger(this, options);
      }
      if (typeof options === 'string') {
        return instance[options].apply(instance, parameters);
      }
    });
  };
  return $.fn.honegger.defaults = {
    multipleSections: true,
    toolbar: '*[data-role="toolbar"]',
    buttons: '*[data-command]',
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
})(jQuery, document, window);
