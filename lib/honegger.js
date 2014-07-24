(function($) {
  var Honegger;
  Honegger = function(element, options) {
    var changeMode, composer, current, enableFeatures, modes;
    composer = $(element);
    modes = {};
    current = void 0;
    enableFeatures = function() {
      var feature, name, spi, _ref, _results;
      spi = {
        mode: function(name, handler) {
          if (!modes[name]) {
            modes[name] = [];
          }
          return modes[name].push(handler);
        }
      };
      _ref = options.features;
      _results = [];
      for (name in _ref) {
        feature = _ref[name];
        _results.push(feature(spi));
      }
      return _results;
    };
    changeMode = function(mode) {
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
    enableFeatures();
    changeMode(options.defaultMode);
    return {
      modes: function() {
        var name, _results;
        _results = [];
        for (name in modes) {
          _results.push(name);
        }
        return _results;
      },
      changeMode: changeMode
    };
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
  $.fn.honegger.features = {};
  return $.fn.honegger.defaults = {};
})(jQuery);

(function($) {})(jQuery);
