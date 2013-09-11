(function($, document, window) {
  var Honegger;
  Honegger = function(element, options) {
    var bindHotkey, composer, currentRange, disable, execCommand, makeComposer, makeComposers, toolbar;
    composer = $(element);
    disable = false;
    composer.data('honegger', this);
    composer.addClass('honegger-composer');
    toolbar = typeof options.toolbar === 'string' ? $(options.toolbar) : options.toolbar;
    $.fn.honegger.initToolbar(composer, toolbar, options);
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
          if (!disable) {
            return execCommand(command);
          }
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
      element.attr('contenteditable', 'true').on('mouseup keyup mouseout focus', function() {
        return $.fn.honegger.updateToolbar(toolbar, options);
      });
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
      this.disable = function() {
        disable = true;
        return composer.find(options.editableSelector).attr('contenteditable', 'false');
      };
      this.enable = function() {
        disable = false;
        return composer.find(options.editableSelector).attr('contenteditable', 'true');
      };
      return makeComposers(composer);
    } else {
      this.disable = function() {
        disable = true;
        return composer.attr('contenteditable', 'false');
      };
      this.enable = function() {
        disable = false;
        return composer.attr('contenteditable', 'true');
      };
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
      if (typeof options === 'string' && (instance[options] != null)) {
        return instance[options].apply(instance, parameters);
      }
    });
  };
  $.fn.honegger.initToolbar = function(composer, toolbar, options) {
    return $(options.buttons, toolbar).each(function() {
      var button;
      button = $(this);
      return button.click(function() {
        return composer.honegger('execCommand', button.attr(options.buttonCommand));
      });
    });
  };
  $.fn.honegger.updateToolbar = function(toolbar, options) {
    return $(options.buttons, toolbar).each(function() {
      var button, command;
      button = $(this);
      command = button.attr(options.buttonCommand);
      if (document.queryCommandState(command)) {
        return button.addClass(options.buttonHighlight);
      } else {
        return button.removeClass(options.buttonHighlight);
      }
    });
  };
  return $.fn.honegger.defaults = {
    multipleSections: true,
    editableSelector: '*[data-role="composer"]',
    toolbar: '*[data-role="toolbar"]',
    buttons: '*[data-command]',
    buttonCommand: 'data-command',
    buttonHighlight: 'honegger-button-active',
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
