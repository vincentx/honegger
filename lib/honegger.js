(function($) {
  var ComposingMode, Honegger;
  ComposingMode = function(composer, api, spi, options) {
    var current, modes;
    modes = {};
    current = void 0;
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
    api.changeMode = function(mode) {
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
    return function() {
      return api.changeMode(options.defaultMode);
    };
  };
  Honegger = function(element, options) {
    var api, composer, feature, initialize, installed, name, spi, _i, _len, _ref;
    composer = $(element);
    api = {};
    spi = {};
    installed = options.extensionPoints.map(function(install) {
      return install(composer, api, spi, options);
    });
    _ref = options.features;
    for (name in _ref) {
      feature = _ref[name];
      feature(spi);
    }
    for (_i = 0, _len = installed.length; _i < _len; _i++) {
      initialize = installed[_i];
      initialize();
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
    extensionPoints: [ComposingMode]
  };
})(jQuery);

(function($) {})(jQuery);
