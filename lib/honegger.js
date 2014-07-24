(function($) {
  var ComposingMode, Honegger;
  ComposingMode = function(composer, api, spi, options) {
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
              return this.off(composer);
            });
          }
          $.each(modes[mode], function() {
            return this.on(composer);
          });
          return current = mode;
        };
      },
      initialize: function() {
        return api.changeMode(options.defaultMode);
      }
    };
  };
  Honegger = function(element, options) {
    var api, composer, plugin, plugins, spi, _i, _j, _k, _len, _len1, _len2;
    composer = $(element);
    api = {};
    spi = {};
    plugins = options.plugins.concat(options.extraPlugins).map(function(plugin) {
      return plugin(composer, api, spi, options);
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

(function($) {})(jQuery);
