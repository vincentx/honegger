var PAGE_LIMITATION;

PAGE_LIMITATION = 6;

$.fn.honegger.page = function(options) {
  var removeControls;
  options = $.extend({}, $.fn.honegger.page.defaults, options);
  removeControls = function(page) {
    $(page).children().each(function() {
      if (!$(this).hasClass("page-content")) {
        return $(this).remove();
      }
    });
    $('.layout-container', page).children().each(function() {
      if (!$(this).hasClass("sections")) {
        return $(this).remove();
      }
    });
    $('.add-column-panel', page).each(function() {
      return $(this).remove();
    });
    return page;
  };
  return {
    dataTemplate: {
      title: 'New Page'
    },
    editor: function(page, config, content) {
      page = page ? page.clone(true) : $(options.template);
      page.find('.column').append(options.addColumnButton());
      page.unbind('click').bind('click', '.add-column', function(e) {
        var columnTemplate, column_type;
        column_type = $(e.target).closest('.add-column').attr('data-column-type');
        if (options.layouts[column_type]) {
          columnTemplate = $(options.layouts[column_type].layout).clone();
          columnTemplate.append(options.addColumnButton());
          return columnTemplate.insertAfter($(e.target).closest('.column'));
        }
      });
      return page;
    },
    control: function(page) {
      if (!page) {
        page = $('<div></div>');
      }
      options.spi.toControl(removeControls(page));
      return page;
    },
    placeholder: function(page) {
      if (!page) {
        page = $('<div></div>');
      }
      page = page.clone();
      options.spi.toPlaceholder(removeControls(page));
      return page;
    }
  };
};

$.fn.honegger.page.defaults = {
  template: '<div>' + '<input type="hidden" data-component-config-key="title" value="">' + '<div class="page-content layout-container">' + '<div class="sections">' + '<div class="column one-column">' + '<div class="section-block active">' + '<div class="section-column component-container">' + '<div class="components"></div>' + '</div>' + '</div>' + '</div>' + '</div>' + '</div>' + '</div>'
};

window.Page = function(api, spi) {
  var options;
  options = {
    addColumnButton: function() {
      return $('<div class="add-column-panel" title="Add layout">' + '<a class="add-column" data-column-type="one-column"><i class="icon icon-columns"></i></a>' + '</div>');
    },
    layouts: {
      'one-column': {
        layout: $('<div class="column one-column">' + '<div class="section-block">' + '<div class="section-column component-container">' + '<div class="components"></div>' + '</div>' + '</div>' + '</div>')
      }
    }
  };
  return {
    extensionPoints: function() {
      return spi.installPage = function(name, config) {
        var page;
        if ($('article div.page-content').length === PAGE_LIMITATION) {
          return false;
        }
        config = $.extend({
          spi: spi
        }, options, config);
        page = $.fn.honegger.page(config);
        spi.installComponent(name, page);
        return spi.composer.trigger('installPage', [name, page]);
      };
    },
    initialize: function() {
      return spi.composer.on('click', '.sections > div', function(event) {
        $('.active-page').find('.sections .active').removeClass('active');
        return $(event.currentTarget).find('.section-block').addClass('active');
      });
    }
  };
};

window.Theme = function(api, spi) {
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

window.PageList = function(api, spi) {
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
