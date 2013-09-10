(function($, document, window) {
  var Honegger;
  Honegger = function(element, options) {
    var bindHotkey, composer, currentRange, execCommand, makeComposer, makeComposers;
    composer = $(element);
    composer.data('honegger', this);
    composer.addClass('honegger-composer');
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
    execCommand = function(command) {
      return document.execCommand(command);
    };
    bindHotkey = function(target, key, command) {
      return target.keydown(key, function(e) {
        if (target.attr('contenteditable') && target.is(':visible')) {
          e.preventDefault();
          e.stopPropagation();
          return execCommand(command);
        }
      }).keyup(key, function(e) {
        if (target.attr('contenteditable') && target.is(':visible')) {
          e.preventDefault();
          return e.stopPropagation();
        }
      });
    };
    makeComposer = function(element) {
      var command, key, _ref, _results;
      element.attr('contenteditable', 'true').on('mouseup keyup mouseout focus', function() {});
      _ref = options.hotkeys;
      _results = [];
      for (key in _ref) {
        command = _ref[key];
        _results.push(bindHotkey(element, key, command));
      }
      return _results;
    };
    makeComposers = function(element) {
      element.find(options.editableSelector).andSelf().filter(options.editableSelector).each(function() {
        return makeComposer($(this));
      });
      return element;
    };
    this.execCommand = function(command) {
      if (currentRange() != null) {
        return execCommand(command);
      }
    };
    if (options.multipleSections) {
      this.insertSection = function(template) {
        return composer.append(makeComposers($(template)));
      };
      return makeComposers(composer);
    } else {
      return makeComposer(composer);
    }
  };
  $.fn.honegger = function(options) {
    var parameters;
    parameters = $.makeArray(arguments).slice(1);
    return this.each(function() {
      var instance;
      instance = $.data(this, 'honegger');
      if (!instance) {
        return new Honegger(this, $.extend({}, $.fn.honegger.defaults, options));
      }
      if (typeof options === 'string') {
        return instance[options].apply(instance, parameters);
      }
    });
  };
  return $.fn.honegger.defaults = {
    multipleSections: true,
    editableSelector: '*[data-role="composer"]',
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
