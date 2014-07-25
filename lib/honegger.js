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
              return this.off(spi.composer);
            });
          }
          $.each(modes[mode], function() {
            return this.on(spi.composer);
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
  var ContentTemplating;
  ContentTemplating = function(api, spi) {
    var components, createComponentEditor, setConfigElementValue;
    components = {};
    setConfigElementValue = function(configElement, value) {
      if (configElement.attr('type') === 'checkbox') {
        return configElement.prop('checked', value);
      } else {
        return configElement.val(value);
      }
    };
    createComponentEditor = function(name, config) {
      var editor;
      editor = components[name].editor("template", config);
      $('*[data-component-config-key]', editor).each(function() {
        var configElement, value;
        configElement = $(this);
        value = eval("config." + (configElement.attr('data-component-config-key')));
        if (value != null) {
          return setConfigElementValue(configElement, value);
        }
      });
      return editor;
    };
    return {
      extensionPoints: function() {
        spi.installComponent = function(name, component) {
          return components[name] = component;
        };
        spi.insertComponent = function(component) {
          return spi.composer.append(component);
        };
        return api.newComponent = function(name, config) {
          if (config == null) {
            config = {};
          }
          if (!components[name]) {
            return $.error("no such component " + name);
          }
          if (api.mode() !== 'edit') {
            return $.error("components can only be created in edit mode");
          }
          return spi.insertComponent(createComponentEditor(name, config));
        };
      },
      extensions: function() {
        spi.mode('edit', {
          on: function(composer) {},
          off: function(composer) {}
        });
        return spi.mode('preview', {
          on: function(composer) {},
          off: function(composer) {}
        });
      }
    };
  };
  $.fn.honegger.defaults.plugins.push(ContentTemplating);
  return $.fn.honegger.defaults.defaultMode = 'edit';
})(jQuery);
