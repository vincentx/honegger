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
        return element.val();
      }
    };
    setValue = function(element, value) {
      if (element.attr('type') === 'checkbox') {
        return element.prop('checked', value);
      } else {
        return element.val(value);
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
    setValues = function(editor, values, selector) {
      $("*[" + selector + "]", editor).each(function() {
        var element, value;
        element = $(this);
        value = eval("values." + (element.attr(selector)));
        if (value != null) {
          return setValue(element, value);
        }
      });
      return editor;
    };
    getValues = function(editor, values, selector) {
      $("*[" + selector + "]", editor).each(function() {
        var element, key;
        element = $(this);
        key = element.attr(selector);
        if (key.indexOf('.') !== -1) {
          ensureExist(values, key);
        }
        return eval("values." + key + " = getValue(element)");
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
      "new": function(component, config, value) {
        var editor;
        if (value == null) {
          value = component.dataTemplate;
        }
        editor = setValues(component.editor(config), config, 'data-component-config-key');
        if (value != null) {
          setValues(editor, value, 'name');
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
    createComponentEditor = function(name, id, config, value) {
      return newComponent(ComponentEditor["new"](components[name], config, value), id, name, config);
    };
    createComponentControl = function(name, id, config, value) {
      return newComponent(components[name].control(value), id, name, config).data('component-content', value);
    };
    createPlaceHolder = function(name, id, config, value) {
      return newComponent($('<div></div>'), id, name, config).data('component-content', value);
    };
    createComponent = function(components, creator) {
      return components().each(function() {
        var component;
        component = $(this);
        return component.replaceWith(creator(component.data('component-type'), component.data('component-id'), ComponentEditor.getConfiguration(component), ComponentEditor.getContent(component)));
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
        spi.insertComponent = function(target, name, config) {
          if (config == null) {
            config = {};
          }
          if (!components[name]) {
            return $.error("no such component " + name);
          }
          if (api.mode() !== 'edit') {
            return $.error("components can only be created in edit mode");
          }
          return target.append(createComponentEditor(name, IdGenerator.next(name), config));
        };
        spi.toEditor = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createComponentEditor);
        };
        spi.toControl = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createComponentControl);
        };
        spi.toPlaceholder = function(target) {
          return createComponent(function() {
            return $('*[data-role="component"]', target);
          }, createPlaceHolder);
        };
        spi.components = function(target) {
          if (target == null) {
            target = spi.composer;
          }
          return $('*[data-role="component"]', target);
        };
        return api.insertComponent = function(name, config) {
          if (config == null) {
            config = {};
          }
          return spi.insertComponent(spi.composer, name, config);
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
  var PageComponent;
  $.fn.honegger.page = function(options) {
    var initComponentContainer, page;
    options = $.extend({}, $.fn.honegger.page.defaults, options);
    page = null;
    initComponentContainer = function(target) {
      $('.component-container', target).each(function() {
        var editor;
        editor = options.componentEditor(options);
        if (editor != null) {
          return $(this).append(editor);
        }
      });
      return target;
    };
    return {
      dataTempalte: {},
      editor: function(config) {
        if (!page) {
          page = $(options.template);
        }
        if ($('.add-layout', page).length !== 0) {
          return page;
        }
        $('.layout-container', page).each(function() {
          return $(this).append(options.layoutEditor(options));
        });
        initComponentContainer(page);
        $('.add-layout', page).click(function() {
          var layout, layoutTemplate;
          layout = $(this).attr('data-layout');
          if (options.layouts[layout]) {
            layoutTemplate = initComponentContainer($(options.layouts[layout].layout));
            $('.add-component', layoutTemplate).click(function() {
              var component;
              component = $(this).attr('data-component');
              return options.spi.insertComponent($('.components', $(this).parents('.component-container')), component);
            });
            return $('.layout-container .sections', page).append(layoutTemplate);
          }
        });
        return page;
      },
      control: function(config) {
        if (!page) {
          page = $('<div></div>');
        }
        $('.layout-container', page).children().each(function() {
          if (!$(this).hasClass("sections")) {
            return $(this).remove();
          }
        });
        $('.component-container', page).children().each(function() {
          if (!$(this).hasClass("components")) {
            return $(this).remove();
          }
        });
        options.spi.toControl(page);
        return page;
      }
    };
  };
  $.fn.honegger.page.defaults = {
    template: '<div>' + '<input type="hidden" data-component-config-key="title" value="">' + '<div class="page-content layout-container"><div class="sections"></div></div>' + '</div>'
  };
  PageComponent = function(api, spi) {
    return {
      extensionPoints: function() {
        return spi.installPage = function(name, config) {
          var page;
          config = $.extend({}, {
            spi: spi
          }, config);
          page = $.fn.honegger.page(config);
          spi.installComponent(name, page);
          return spi.composer.trigger('installPage', [name, page]);
        };
      }
    };
  };
  return $.fn.honegger.defaults.plugins.push(PageComponent);
})(jQuery);

(function($) {
  var PageListComponent;
  PageListComponent = function(api, spi) {
    var initEvents, installPage, options;
    options = {
      template: '<div class="page-tab">' + '<span class="title"></span>' + '<input type="text" class="hide">' + '<div class="button-group default-mode">' + '<i class="glyphicon glyphicon-pencil edit-page"></i>' + '<i class="glyphicon glyphicon-trash remove-page"></i>' + '</div>' + '<div class="button-group edit-mode hide">' + '<i class="glyphicon glyphicon-ok save-edit"></i>' + '<i class="glyphicon glyphicon-remove cancel-edit"></i>' + '</div>' + '</div>'
    };
    installPage = function(pageList, title) {
      var addButton, page;
      page = $(options.template);
      addButton = pageList.find('.add-page');
      page.insertBefore(addButton).find('.title').html(title);
      if ($('.active-page').length === 0) {
        return page.addClass('active-page');
      }
    };
    initEvents = function() {
      return $('.page-list-container').on('click', '.add-page', function(e) {
        e.stopPropagation();
        spi.installPage('new page', {});
        return spi.composer.honegger('insertComponent', 'blank');
      });
    };
    return {
      extensionPoints: function() {
        return spi.initPageList = function(pageListContainer) {
          spi.composer.append(pageListContainer);
          return pageListContainer;
        };
      },
      extensions: function() {
        var pageList;
        pageList = spi.initPageList($('.page-list').clone().addClass('page-list-container'));
        return spi.composer.on('installPage', function(event, name, page) {
          return installPage(pageList, name);
        });
      },
      initialize: function() {
        return initEvents();
      }
    };
  };
  return $.fn.honegger.defaults.plugins.push(PageListComponent);
})(jQuery);

(function($) {
  var ThemeComponent;
  ThemeComponent = function(api, spi) {
    var initEvents;
    initEvents = function() {
      return $('*[data-theme]').on('click', function(e) {
        var frameId, target;
        target = $(e.currentTarget);
        frameId = target.attr('data-target');
        $(frameId + '-frame')[0].contentWindow.postMessage('preview', 'http://' + location.host);
      });
    };
    return {
      extensionPoints: function() {},
      extensions: function() {},
      initialize: function() {
        return initEvents();
      }
    };
  };
  return $.fn.honegger.defaults.plugins.push(ThemeComponent);
})(jQuery);
