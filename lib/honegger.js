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
    var ensureExist, getValue, getValues, setValue, setValues;
    getValue = function(element) {
      if (element.attr('type') === 'checkbox') {
        return element.is(':checked');
      } else {
        if (element.data('component-config-type') === 'json') {
          return JSON.parse(element.val());
        } else {
          return element.val();
        }
      }
    };
    setValue = function(element, value) {
      if (element.attr('type') === 'checkbox') {
        return element.prop('checked', value);
      } else {
        if (element.data('component-config-type') === 'json') {
          return element.val(JSON.stringify(value));
        } else {
          return element.val(value);
        }
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
    setValues = function(editor, values, selector, filter_selector) {
      if (filter_selector == null) {
        filter_selector = "data-role='component'";
      }
      $("[" + selector + "]", editor).not($("[" + filter_selector + "] [" + selector + "]", editor)).each(function() {
        var element, value;
        element = $(this);
        value = eval("values." + (element.attr(selector)));
        if (value != null) {
          return setValue(element, value);
        }
      });
      return editor;
    };
    getValues = function(editor, values, selector, filter_selector) {
      if (filter_selector == null) {
        filter_selector = "data-role='component'";
      }
      $("[" + selector + "]", editor).not($("[" + filter_selector + "] [" + selector + "]", editor)).each(function() {
        var element, key;
        element = $(this);
        key = element.attr(selector);
        if (key.indexOf('.') !== -1) {
          ensureExist(values, key);
        }
        eval("values." + key + " = getValue(element)");
        return true;
      });
      return values;
    };
    return {
      getConfiguration: function(editor) {
        return getValues(editor, editor.data('component-config') || {}, 'data-component-config-key');
      },
      getContent: function(editor) {
        return getValues(editor, editor.data('component-content') || {}, 'name');
      },
      create: function(target, component, config, content) {
        var editor;
        editor = setValues(component.editor(target, config, content), config, 'data-component-config-key');
        if (content != null) {
          setValues(editor, content, 'name');
        }
        return editor;
      }
    };
  })();
  ContentComponent = function(api, spi) {
    var IdGenerator, components, createComponent, createComponentControl, createComponentEditor, createPlaceHolder, destroyComponent, newComponent;
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
    createComponentEditor = function(target, name, id, config, content) {
      return newComponent(ComponentEditor.create(target, components[name], config, content), id, name, config);
    };
    createComponentControl = function(target, name, id, config, content) {
      return newComponent(components[name].control(target, config, content), id, name, config).data('component-content', content);
    };
    createPlaceHolder = function(target, name, id, config, content) {
      var placeholder;
      placeholder = components[name].placeholder != null ? components[name].placeholder(target) : $('<div></div>');
      return newComponent(placeholder, id, name, config).data('component-content', content);
    };
    createComponent = function(components, creator, target) {
      return components().map(function() {
        return $(this).data('component-id');
      }).each(function(index, id) {
        var component;
        component = $("[data-component-id='" + id + "']", target);
        return component.replaceWith(creator(component, component.data('component-type'), id, ComponentEditor.getConfiguration(component), ComponentEditor.getContent(component)));
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
        spi.insertComponent = function(target, name, config, content) {
          if (config == null) {
            config = {};
          }
          if (content == null) {
            content = {};
          }
          if (!components[name]) {
            return $.error("no such component " + name);
          }
          if (api.mode() !== 'edit') {
            return $.error("components can only be created in edit mode");
          }
          return target.append(createComponentEditor(null, name, IdGenerator.next(name), config, $.extend(components[name].dataTemplate, content)));
        };
        spi.toEditor = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createComponentEditor, target);
        };
        spi.toControl = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createComponentControl, target);
        };
        spi.toPlaceholder = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createPlaceHolder, target);
        };
        spi.getPlaceholder = function(component) {
          return createPlaceHolder(component, component.data('component-type'), component.data('component-id'), ComponentEditor.getConfiguration(component), ComponentEditor.getContent(component));
        };
        spi.getComponentConfiguration = function(component) {
          return ComponentEditor.getConfiguration(component);
        };
        spi.getComponentContent = function(component) {
          return ComponentEditor.getContent(component);
        };
        spi.components = function(target) {
          if (target == null) {
            target = spi.composer;
          }
          return $('*[data-role="component"]', target);
        };
        return api.insertComponent = function(name, config, content) {
          if (config == null) {
            config = {};
          }
          return spi.insertComponent(spi.composer, name, config, content);
        };
      },
      extensions: function() {
        spi.mode('edit', {
          on: function() {
            return spi.toEditor(spi.composer);
          },
          off: function() {
            return destroyComponent('destroyEditor');
          }
        });
        return spi.mode('preview', {
          on: function() {
            return spi.toControl(spi.composer);
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

(function($) {
  var ContentTemplate;
  ContentTemplate = function(api, spi) {
    var decodeContent;
    decodeContent = function(value) {
      if (value.content && $.type(value.content) === 'object') {
        return decodeContent(value.content);
      } else if ($.type(value.content) === 'string') {
        return value.content = $('<div/>').html(value.content).text();
      }
    };
    return {
      extensionPoints: function() {
        api.getContentTemplate = function() {
          var composer, config, content;
          composer = spi.composer.clone();
          config = {};
          content = {};
          spi.components().each(function() {
            var component;
            component = $(this);
            config[component.data('component-id')] = $.extend({}, spi.getComponentConfiguration(component), {
              type: component.data('component-type')
            });
            return content[component.data('component-id')] = $.extend({}, spi.getComponentContent(component), {
              type: component.data('component-type')
            });
          });
          spi.components(composer).each(function() {
            var component;
            component = $(this);
            if (component.parents('*[data-role="component"]').length !== 0) {
              return;
            }
            return component.replaceWith(spi.getPlaceholder($(this))[0].outerHTML);
          });
          return {
            template: composer.html(),
            config: config,
            content: content
          };
        };
        return api.loadContentTemplate = function(template, config, content, mode) {
          spi.composer.html(template);
          $.each(config, function(key, value) {
            return $("[data-component-id='" + key + "']", spi.composer).data('component-config', value);
          });
          $.each(content, function(key, value) {
            decodeContent(value);
            return $("[data-component-id='" + key + "']", spi.composer).data('component-content', value);
          });
          api.changeMode(mode);
          return spi.composer.trigger('honegger.syncPages');
        };
      }
    };
  };
  return $.fn.honegger.defaults.plugins.push(ContentTemplate);
})(jQuery);
