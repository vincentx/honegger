(function($, document, window) {
  var Honegger;
  Honegger = function(element, options) {
    var bindHotkey, changeMode, components, composer, currentRange, disable, disabled, editMode, enable, execCommand, insideComposer, makeComposer, makeComposers, mode, notInsideComponent, previewMode, self, toolbar;
    self = this;
    composer = $(element);
    components = {};
    disabled = false;
    mode = 'edit';
    composer.data('honegger', this);
    composer.addClass('honegger-composer');
    toolbar = typeof options.toolbar === 'string' ? $(options.toolbar) : options.toolbar;
    $.fn.honegger.initToolbar(composer, toolbar, options);
    insideComposer = function(range) {
      return $.inArray(element, $(range.startContainer).parents()) !== -1;
    };
    notInsideComponent = function(range) {
      return $(range.startContainer).parents(options.componentSelector).length === 0;
    };
    currentRange = function() {
      var range, selection;
      selection = window.getSelection();
      if (selection.rangeCount) {
        range = selection.getRangeAt(0);
        if (insideComposer(range) && notInsideComponent(range)) {
          return range;
        }
      }
    };
    execCommand = function(command, args) {
      if (args != null) {
        return document.execCommand(command, false, args);
      } else {
        return document.execCommand(command);
      }
    };
    bindHotkey = function(target, key, command) {
      return target.keydown(key, function(e) {
        if (target.attr('contenteditable') && target.is(':visible')) {
          e.preventDefault();
          e.stopPropagation();
          if (!disabled && (currentRange() != null)) {
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
    disable = function(editable) {
      disabled = true;
      return editable.attr('contenteditable', 'false');
    };
    enable = function(editable) {
      disabled = false;
      return editable.attr('contenteditable', 'true');
    };
    changeMode = function(element, handler) {
      var component, config, type;
      config = element.data('component-config');
      type = element.data('component-type');
      $(options.configurationSelector, element).each(function() {
        return config[$(this).attr(options.configuration)] = $(this).val();
      });
      component = components[element.data('component-type')];
      return element.replaceWith(handler(component, config).data('component-config', config).attr('data-component-type', type).attr('data-role', 'component'));
    };
    editMode = function(element) {
      self.enable();
      return changeMode(element, function(component, config) {
        var editor;
        editor = component.editor(options.componentEditorTemplate, config);
        $(options.configurationSelector, editor).each(function() {
          var configElement;
          configElement = $(this);
          if (configElement.attr(options.configuration) != null) {
            return configElement.val(config[configElement.attr(options.configuration)]);
          }
        });
        return editor;
      });
    };
    previewMode = function(element) {
      self.disable();
      return changeMode(element, function(component) {
        return component.control();
      });
    };
    this.execCommand = function(command, args) {
      if (!disabled && (currentRange() != null)) {
        return execCommand(command, args);
      }
    };
    this.insertComponent = function(name) {
      var editor, range;
      if (!(disabled || (components[name] != null))) {
        return;
      }
      range = currentRange();
      if (range == null) {
        return;
      }
      editor = components[name].editor(options.componentEditorTemplate, {});
      editor.data('component-config', {}).attr('data-component-type', name).attr('data-role', 'component');
      return range.insertNode(editor[0]);
    };
    this.installComponent = function(name, component) {
      return components[name] = component;
    };
    this.changeMode = function(new_mode) {
      var handler;
      mode = new_mode;
      handler = mode === 'edit' ? editMode : previewMode;
      return composer.find(options.componentSelector).each(function() {
        return handler($(this));
      });
    };
    if (options.multipleSections) {
      this.insertSection = function(template) {
        if (!disabled) {
          return composer.append(makeComposers($(template)));
        }
      };
      this.disable = function() {
        return disable(composer.find(options.editableSelector));
      };
      this.enable = function() {
        return enable(composer.find(options.editableSelector));
      };
      return makeComposers(composer);
    } else {
      this.disable = function() {
        return disable(composer);
      };
      this.enable = function() {
        return enable(composer);
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
    componentSelector: '*[data-role="component"]',
    configurationSelector: 'input[data-component-config]',
    configuration: 'data-component-config',
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
    },
    componentEditorTemplate: '<table contenteditable="false">' + '<thead><tr><td class="component-header"></td></tr></thead>' + '<tbody><tr><td class="component-content"></td></tr></tbody>' + '</table>'
  };
})(jQuery, document, window);
