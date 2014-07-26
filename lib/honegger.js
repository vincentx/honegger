(function($) {
  var ComposingMode, Honegger;
  ComposingMode = function(api, spi) {
    var current, modes;
    modes = {};
    current = void 0;
    return {
      extensionPoints: function() {
        spi.mode = function(name, handler) {
          if (!modes[name]) {
            modes[name] = [];
          }
          return modes[name].push(handler);
        };
        api.mode = function() {
          return current;
        };
        api.modes = function() {
          var name, _results;
          _results = [];
          for (name in modes) {
            _results.push(name);
          }
          return _results;
        };
        return api.changeMode = function(mode) {
          if (!modes[mode]) {
            $.error("no such mode " + mode);
          }
          if (current && modes[current]) {
            $.each(modes[current], function() {
              return this.off();
            });
          }
          $.each(modes[mode], function() {
            return this.on();
          });
          return current = mode;
        };
      },
      initialize: function() {
        return api.changeMode(spi.options.defaultMode);
      }
    };
  };
  Honegger = function(element, options) {
    var api, composer, plugin, plugins, spi, _i, _j, _k, _len, _len1, _len2;
    composer = $(element);
    api = {};
    spi = {
      composer: composer,
      options: options
    };
    plugins = options.plugins.concat(options.extraPlugins).map(function(plugin) {
      return plugin(api, spi);
    });
    for (_i = 0, _len = plugins.length; _i < _len; _i++) {
      plugin = plugins[_i];
      if (plugin.extensionPoints) {
        plugin.extensionPoints();
      }
    }
    for (_j = 0, _len1 = plugins.length; _j < _len1; _j++) {
      plugin = plugins[_j];
      if (plugin.extensions) {
        plugin.extensions();
      }
    }
    for (_k = 0, _len2 = plugins.length; _k < _len2; _k++) {
      plugin = plugins[_k];
      if (plugin.initialize) {
        plugin.initialize();
      }
    }
    return api;
  };
  $.fn.honegger = function(options) {
    var initComponent, isMethodCall, methodCall, parameters, returnValue;
    isMethodCall = typeof options === 'string';
    parameters = $.makeArray(arguments).slice(1);
    returnValue = this;
    methodCall = function() {
      var instance, value;
      instance = $.data(this, 'honegger');
      if (!instance[options]) {
        return $.error("no such method " + options);
      }
      value = instance[options].apply(instance, parameters);
      if (value !== instance && value) {
        returnValue = value;
        return false;
      }
    };
    initComponent = function() {
      var instance;
      instance = $.data(this, 'honegger');
      if (!instance) {
        return $.data(this, 'honegger', new Honegger(this, $.extend({}, $.fn.honegger.defaults, options)));
      }
    };
    this.each(isMethodCall ? methodCall : initComponent);
    return returnValue;
  };
  return $.fn.honegger.defaults = {
    plugins: [ComposingMode],
    extraPlugins: []
  };
})(jQuery);

(function($) {
  var ComponentEditor, ContentComponent;
  ComponentEditor = (function() {
    var ensureExist, getConfigElementValue, setConfigElementValue;
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
    ensureExist = function(config, key) {
      var field, struct, _i, _len, _ref, _results;
      struct = config;
      _ref = key.split('.');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        if (struct[field] == null) {
          struct[field] = {};
        }
        _results.push(struct = struct[field]);
      }
      return _results;
    };
    return {
      getConfiguration: function(editor) {
        var config;
        config = editor.data('component-config') || {};
        $('*[data-component-config-key]', editor).each(function() {
          var configElement, key;
          configElement = $(this);
          key = configElement.data('component-config-key');
          if (key.indexOf('.') !== -1) {
            ensureExist(config, key);
          }
          return eval("config." + key + " = getConfigElementValue(configElement)");
        });
        return config;
      },
      setConfiguration: function(editor, config) {
        $('*[data-component-config-key]', editor).each(function() {
          var configElement, value;
          configElement = $(this);
          value = eval("config." + (configElement.data('component-config-key')));
          if (value != null) {
            return setConfigElementValue(configElement, value);
          }
        });
        return editor;
      }
    };
  })();
  ContentComponent = function(api, spi) {
    var IdGenerator, components, createComponent, createComponentControl, createComponentEditor, destroyComponent, newComponent;
    components = {};
    IdGenerator = (function() {
      var componentIds;
      componentIds = {};
      return {
        next: function(type) {
          if (componentIds[type] == null) {
            componentIds[type] = 1;
          }
          while ($("[data-component-id='" + type + "-" + componentIds[type] + "']", spi.composer).length !== 0) {
            componentIds[type] = componentIds[type] + 1;
          }
          return "" + type + "-" + componentIds[type];
        }
      };
    })();
    newComponent = function(component, id, type, config) {
      return component.data('component-config', config).attr('data-role', 'component').attr('data-component-type', type).attr('data-component-id', id);
    };
    createComponentEditor = function(name, id, config) {
      var editor;
      editor = components[name].editor("template", config);
      return newComponent(ComponentEditor.setConfiguration(editor, config), id, name, config);
    };
    createComponentControl = function(name, id, config, value) {
      return newComponent(components[name].control("template", value), id, name, config);
    };
    createComponent = function(creator) {
      return spi.components().each(function() {
        var component;
        component = $(this);
        return component.replaceWith(creator(component.data('component-type'), component.data('component-id'), ComponentEditor.getConfiguration(component), {}));
      });
    };
    destroyComponent = function(destroy) {
      return spi.components().each(function() {
        var component, type;
        component = $(this);
        type = components[component.data('component-type')];
        if (!type) {
          return $.error("no such component " + (component.data('component-type')));
        }
        if (type[destroy]) {
          return type[destroy](component);
        }
      });
    };
    return {
      extensionPoints: function() {
        spi.installComponent = function(name, component) {
          return components[name] = component;
        };
        spi.insertComponent = function(component) {
          return spi.composer.append(component);
        };
        spi.components = function() {
          return $('*[data-role="component"]', spi.composer);
        };
        return api.insertComponent = function(name, config) {
          if (config == null) {
            config = {};
          }
          if (!components[name]) {
            return $.error("no such component " + name);
          }
          if (api.mode() !== 'edit') {
            return $.error("components can only be created in edit mode");
          }
          return spi.insertComponent(createComponentEditor(name, IdGenerator.next(name), config));
        };
      },
      extensions: function() {
        spi.mode('edit', {
          on: function() {
            return createComponent(createComponentEditor);
          },
          off: function() {
            return destroyComponent('destroyEditor');
          }
        });
        return spi.mode('preview', {
          on: function() {
            return createComponent(createComponentControl);
          },
          off: function() {
            return destroyComponent('destroyControl');
          }
        });
      }
    };
  };
  $.fn.honegger.defaults.plugins.push(ContentComponent);
  return $.fn.honegger.defaults.defaultMode = 'edit';
})(jQuery);
