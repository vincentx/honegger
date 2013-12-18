(function($, document, window) {
  var Honegger;
  Honegger = function(element, options) {
    var bindHotkey, components, composer, currentRange, disabled, enable, execCommand, initComposer, insideComposer, makeComposer, makeComposers, notInsideComponent, self, toolbar;
    self = this;
    disabled = false;
    composer = $(element).data('honegger', this).addClass('honegger-composer');
    components = $.fn.honegger.components(composer, options);
    toolbar = typeof options.toolbar === 'string' ? $(options.toolbar) : options.toolbar;
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
    enable = function(enabled) {
      return (options.multipleSections ? composer.find(options.editableSelector) : composer).attr('contenteditable', !(disabled = !enabled));
    };
    initComposer = function() {
      if (options.multipleSections) {
        return makeComposers(composer);
      } else {
        return makeComposer(composer);
      }
    };
    this.execCommand = function(command, args) {
      if (!disabled && (currentRange() != null)) {
        return execCommand(command, args);
      }
    };
    this.insertComponent = function(name, config) {
      var range;
      if (config == null) {
        config = {};
      }
      if (!(!disabled && (components.get(name) != null) && (range = currentRange()))) {
        return;
      }
      return range.insertNode(components.newComponent(name, config)[0]);
    };
    this.installComponent = components.install;
    this.changeMode = function(mode, config) {
      enable(mode === 'edit');
      return composer.find(options.componentSelector).each(function() {
        return components.modes[mode]($(this), config);
      });
    };
    this.getTemplate = function(handler) {
      return components.getTemplate(composer, function(html, dataTemplate, configurations) {
        return handler(html, dataTemplate, configurations);
      });
    };
    this.loadContent = function(content, mode, configuration) {
      composer.html(content);
      components.setConfiguration(configuration);
      initComposer();
      return self.changeMode(mode);
    };
    this.disable = function() {
      return enable(false);
    };
    this.enable = function() {
      return enable(true);
    };
    if (options.multipleSections) {
      this.insertSection = function(template) {
        if (!disabled) {
          return composer.append(makeComposers($(template)));
        }
      };
    }
    initComposer();
    return $.fn.honegger.initToolbar(composer, toolbar, options);
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
    configurationSelector: '*[data-component-config-key]',
    configuration: 'data-component-config-key',
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
    componentEditorTemplate: '<table contenteditable="false">' + '<thead><tr><td class="component-header"></td></tr></thead>' + '<tbody><tr><td class="component-content"></td></tr></tbody>' + '</table>',
    componentPlaceholder: '<div></div>'
  };
})(jQuery, document, window);

(function($) {
  return $.fn.honegger.components = function(composer, options) {
    var changeMode, componentIds, components, config, generateId, getConfigElementValue, getConfiguration, setConfigElementValue, setConfiguration;
    components = {};
    componentIds = {};
    generateId = function(type) {
      if (componentIds[type] == null) {
        componentIds[type] = 1;
      }
      while ($("[data-component-id='" + type + "-" + componentIds[type] + "']", composer).length !== 0) {
        componentIds[type] = componentIds[type] + 1;
      }
      return "" + type + "-" + componentIds[type];
    };
    getConfiguration = function(element) {
      var config;
      config = element.data('component-config') || {};
      $(options.configurationSelector, element).each(function() {
        var configElement, field, key, struct, _i, _len, _ref;
        configElement = $(this);
        key = configElement.attr(options.configuration);
        if (key.indexOf('.') !== -1) {
          struct = config;
          _ref = key.split('.');
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            field = _ref[_i];
            if (struct[field] == null) {
              struct[field] = {};
            }
            struct = struct[field];
          }
          eval("config." + key + " = getConfigElementValue(configElement)");
        } else {
          config[key] = getConfigElementValue(configElement);
        }
      });
      return config;
    };
    getConfigElementValue = function(configElement) {
      if (configElement.attr('type') === 'checkbox') {
        return configElement.is(':checked');
      } else {
        return configElement.val();
      }
    };
    setConfigElementValue = function(configElement, value) {
      if (configElement.attr('type') === 'checkbox') {
        return configElement.prop('checked', value);
      } else {
        return configElement.val(value);
      }
    };
    setConfiguration = function(editor, config) {
      $(options.configurationSelector, editor).each(function() {
        var configElement, key, value;
        configElement = $(this);
        key = configElement.attr(options.configuration);
        value = key.indexOf('.') !== -1 ? eval("config." + key) : config[key];
        if (value != null) {
          return setConfigElementValue(configElement, value);
        }
      });
      return editor;
    };
    config = function(target, id, type, config) {
      return target.data('component-config', config).attr('data-component-type', type).attr('data-role', 'component').attr('data-component-id', id);
    };
    changeMode = function(element, handler) {
      var configuration;
      configuration = getConfiguration(element);
      return element.replaceWith(config(handler(components[element.data('component-type')], configuration), element.data('component-id'), element.data('component-type'), configuration));
    };
    return {
      install: function(name, component) {
        return components[name] = component;
      },
      newComponent: function(name, component_config) {
        var component_id;
        component_id = generateId(name);
        component_config = $.extend(true, {
          component_id: component_id
        }, component_config);
        return setConfiguration(config(components[name].editor(options.componentEditorTemplate, component_config), component_id, name, component_config), component_config);
      },
      modes: {
        edit: function(element, config) {
          return changeMode(element, function(component, config) {
            return setConfiguration(component.editor(options.componentEditorTemplate, config), config);
          });
        },
        control: function(element, config) {
          return changeMode(element, function(component) {
            return component.control(config[element.data('component-id')]);
          });
        }
      },
      setConfiguration: function(configuration) {
        return $(options.componentSelector, composer).each(function() {
          var component;
          component = $(this);
          return component.data('component-config', configuration[component.data('component-id')]);
        });
      },
      getTemplate: function(template, handler) {
        var configurations, dataTemplate, page;
        dataTemplate = {};
        configurations = {};
        template.find(options.componentSelector).each(function() {
          var component, id, type;
          component = $(this);
          id = component.data('component-id');
          type = component.data('component-type');
          dataTemplate[id] = $.extend(true, {}, components[type].dataTemplate);
          return configurations[id] = getConfiguration(component);
        });
        page = template.clone();
        page.find(options.editableSelector).removeAttr('contenteditable');
        page.find(options.componentSelector).each(function() {
          var component, id, type;
          component = $(this);
          id = component.data('component-id');
          type = component.data('component-type');
          return component.replaceWith(config($(options.componentPlaceholder), id, type, {}));
        });
        return handler(page.html(), dataTemplate, configurations);
      },
      get: function(name) {
        return components[name];
      }
    };
  };
})(jQuery);
