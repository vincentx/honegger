(function($) {
  var Honegger;
  Honegger = function(element, options) {
    var composer, feature, modes, name, spi, _ref;
    composer = $(element);
    modes = {};
    spi = {
      mode: function(name, handler) {
        return modes[name] = handler;
      }
    };
    _ref = options.features;
    for (name in _ref) {
      feature = _ref[name];
      feature(spi);
    }
    return {
      modes: function() {
        var _results;
        _results = [];
        for (name in modes) {
          _results.push(name);
        }
        return _results;
      },
      changeMode: function(mode) {}
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
