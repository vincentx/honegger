window.Column = function(api, spi) {
  var base, column, column_panel, columns;
  base = '<div class="column">' + '<div class="section-block"></div>' + '</div>';
  column = '<div class="section-column component-container">' + '<div class="components"></div>' + '</div>';
  columns = {
    single: $('.section-block', $(base)).append(column).parent(),
    'two-equals': $('.section-block', $(base)).append(column).append(column).parent(),
    'one-with-left-sidebar': $('.section-block', $(base)).append($(column).addClass('section-sidebar')).append(column).parent(),
    'one-with-right-sidebar': $('.section-block', $(base)).append(column).append($(column).addClass('section-sidebar')).parent(),
    'three-equals': $('.section-block', $(base)).append(column).append(column).append(column).parent(),
    'one-with-two-sidebars': $('.section-block', $(base)).append($(column).addClass('section-sidebar')).append(column).append($(column).addClass('section-sidebar')).parent()
  };
  column_panel = '<div class="column-container">\
           <div class="add-column-panel">\
            <a class="add-column-button"><i class="icon icon-columns"></i></a>\
           </div>\
           <div class="column-select-panel" title="Add layout">\
            <p>Choose column you want to insert</p>\
            <ul>\
              <li class="add-column" data-column-type="single">\
                <div class="option-block">\
                 <div class="option-column"></div>\
                </div>\
              </li>\
              <li class="add-column" data-column-type="two-equals">\
                <div class="option-block">\
                  <div class="option-column"></div>\
                  <div class="option-column"></div>\
                </div>\
              </li>\
              <li class="add-column" data-column-type="one-with-left-sidebar">\
                <div class="option-block">\
                  <div class="option-column section-sidebar"></div>\
                  <div class="option-column"></div>\
                </div>\
              </li>\
              <li class="add-column" data-column-type="one-with-right-sidebar">\
                <div class="option-block">\
                  <div class="option-column"></div>\
                  <div class="option-column section-sidebar"></div>\
                </div>\
              </li>\
              <li class="add-column" data-column-type="three-equals">\
                <div class="option-block">\
                  <div class="option-column"></div>\
                  <div class="option-column"></div>\
                  <div class="option-column"></div>\
                </div>\
              </li>\
              <li class="add-column" data-column-type="one-with-two-sidebars">\
                <div class="option-block">\
                  <div class="option-column section-sidebar"></div>\
                  <div class="option-column"></div>\
                  <div class="option-column section-sidebar"></div>\
                </div>\
              </li>\
            </ul>\
          </div>\
        </div>';
  return {
    extensionPoints: function() {
      spi.getColumn = function(column_type) {
        if (columns[column_type]) {
          return $(columns[column_type].clone()).addClass(column_type);
        } else {
          return $('');
        }
      };
      spi.setColumn = function(column_type, column_dom) {
        return columns[column_type] = column_dom;
      };
      return spi.addColumnButton = function(page) {
        return page.find('.column').append($(column_panel));
      };
    },
    extensions: $.noop,
    initialize: function() {
      spi.composer.on('click', '.section-column', function(event) {
        var add_column_panel, add_column_panel_container, left;
        $('.active-page').find('.column').find('.section-column.active').removeClass('active').end().find('.column-container.active').removeClass('active');
        add_column_panel_container = $(event.currentTarget).addClass('active').parents('.column').find('.column-container');
        add_column_panel_container.addClass('active');
        add_column_panel = add_column_panel_container.find('.add-column-panel');
        left = $(event.currentTarget).offset().left;
        return add_column_panel.offset({
          left: left
        });
      });
      spi.composer.on('click', '.add-column-panel', function() {
        return $(this).css({
          'visibility': 'hidden'
        }).next('.column-select-panel').show();
      }).on('click', 'li', function() {
        return $(this).closest('.column-select-panel').hide().prev('div.add-column-panel').css({
          'visibility': 'visible'
        });
      });
      spi.composer.on('click', '.add-column', function(e) {
        var columnTemplate, column_type;
        column_type = $(this).attr('data-column-type');
        if (spi.getColumn(column_type)) {
          columnTemplate = $(spi.getColumn(column_type)).clone();
          columnTemplate.append($(column_panel));
          return columnTemplate.insertAfter($(e.currentTarget).closest('.column'));
        }
      });
      return spi.composer.closest('.composer').on('document-click', function(e, target) {
        if ($(target).closest('.add-column-panel').length === 0 && $(target).closest('.column-select-panel').length === 0) {
          $('.column-select-panel').hide();
          return $('.add-column-panel').css({
            'visibility': 'visible'
          });
        }
      });
    }
  };
};

window.ComponentList = function(api, spi) {
  var initEvents, list;
  list = $('.composer .components-container .components-list');
  initEvents = function() {
    return list.on('click', '.add-component', function() {
      var active_column, type;
      type = $(this).attr('data-component-type');
      if (!type) {
        return;
      }
      active_column = $('.active-page .sections .section-column.active .components', spi.composer);
      return spi.insertComponent(active_column, type);
    });
  };
  return {
    extensionPoints: $.noop,
    extensions: $.noop,
    initialize: function() {
      var component, type;
      for (type in HoneggerComponents) {
        component = HoneggerComponents[type];
        spi.installComponent(type, component);
      }
      return initEvents();
    }
  };
};

var PAGE_NUMBER_LIMITATION;

PAGE_NUMBER_LIMITATION = 7;

window.PageList = function(api, spi) {
  var append_new_page_control, assign_page_order, build_page_control_by_page_order, container, controls, highlight_page, indicators, initEvents, locate_page, options, order_pages;
  options = {
    template: '<li>' + '<div class="page-tab">' + '<span class="title"></span>' + '<input type="text" class="form-control edit-title hide" placeholder="page name" maxlength="20">' + '<div class="button-group default-mode">' + '<i class="icon icon-pencil-1 edit-page"></i>' + '<i class="icon remove-page icon-trash"></i>' + '</div>' + '<div class="button-group edit-mode hide">' + '<i class="icon icon-ok save-edit"></i>' + '<i class="icon icon-cancel cancel-edit"></i>' + '</div>' + '</div>' + '</li>',
    indicator_template: '<li data-toggle="tooltip"><i></i></li>',
    tooltip: {
      placement: 'right auto',
      delay: 100,
      container: 'body'
    }
  };
  container = $('.composer .create-page-container');
  indicators = container.find('.page-list-indicator .page-order-list');
  controls = container.find('.page-list .page-order-list');
  order_pages = container.find('.page-order-list');
  locate_page = function(target) {
    var page_id;
    order_pages.find('li.active-page-tab').removeClass('active-page-tab');
    page_id = target.attr('data-page-id');
    order_pages.find("li[data-page-id='" + page_id + "']").addClass('active-page-tab');
    spi.composer.find('.active-page').removeClass('active-page');
    return spi.composer.find("[data-component-id='" + page_id + "']").find('.page-content').addClass('active-page').find('.column-container').removeClass('active').end().find('.column-container:first').addClass('active').end().find('.section-block:first').addClass('active').end().find('.section-column').removeClass('active').end().find('.section-column:first').addClass('active');
  };
  build_page_control_by_page_order = function() {
    var contents;
    order_pages.find('li').remove();
    contents = spi.composer.find('[data-component-type="page"]').map(function(index, item) {
      var page;
      page = $(item);
      return $.extend({
        id: page.attr('data-component-id')
      }, page.data('component-content'));
    });
    contents = _.sortBy(contents, function(item) {
      return item.order;
    });
    return _.each(contents, function(item) {
      return append_new_page_control(item.title, item.id);
    });
  };
  assign_page_order = function() {
    return controls.find('li').each(function(index, item) {
      var page_id;
      page_id = $(item).attr('data-page-id');
      return spi.composer.find("[data-component-id='" + page_id + "'] > input[name='order']").val(index);
    });
  };
  initEvents = function() {
    var time;
    container.on('click', '.add-page', function(e) {
      if (spi.composer.find('[data-component-type="page"]').length !== PAGE_NUMBER_LIMITATION) {
        return api.insertPage('blank');
      }
    });
    $('.page-order-list').on('click', 'li', function(e) {
      return locate_page($(e.currentTarget));
    });
    $('.page-list-indicator').on('click', '.open-create-bar', function(e) {
      return $('.page-list-container').css('margin-left', '0px').focus();
    });
    time = null;
    $('.page-list-container').mouseleave(function() {
      var self;
      self = $(this);
      return time = setTimeout(function() {
        $('.remove-page', self).popover('hide');
        self.css('margin-left', '-220px');
        return $('.edit-mode').not('.hide').find('.cancel-edit').click();
      }, 1000);
    });
    $('.page-list-container').mouseenter(function() {
      return clearTimeout(time);
    });
    container.find('.add-page').tooltip(options.tooltip);
    return controls.sortable({
      cursor: 'move',
      opacity: 0.5,
      containment: '.page-list',
      stop: function() {
        var indicator_container, indicator_items;
        $('.page-list-container .page-order-list li').each(function(index, item) {
          var highlight_item, original_id;
          item = $(item);
          original_id = item.attr('data-page-id');
          $("[data-component-id='" + original_id + "']").data('page-order', index);
          if (item.hasClass('active-page-tab')) {
            $('.page-list-indicator .page-order-list li').removeClass('active-page-tab');
            highlight_item = _.find($('.page-list-indicator .page-order-list li'), function(i) {
              return $(i).attr('data-page-id') === original_id;
            });
            return $(highlight_item).addClass('active-page-tab');
          }
        });
        spi.composer.find('[data-component-type="page"]').each(function(_, page) {
          var index;
          page = $(page);
          index = page.data('page-order');
          return page.find('input[name="order"]').val(index);
        });
        indicator_items = $('.page-list-indicator .page-order-list li').remove();
        indicator_container = $('.page-list-indicator .page-order-list');
        return controls.find('li').each(function(i, list) {
          var indicator;
          indicator = _.find(indicator_items, function(item) {
            return $(item).attr('data-page-id') === $(list).attr('data-page-id');
          });
          $(indicator).tooltip(options.tooltip);
          return indicator_container.append(indicator);
        });
      }
    });
  };
  highlight_page = function(current) {
    var current_page;
    order_pages.find('.active-page-tab').removeClass('active-page-tab');
    order_pages.find(current).addClass('active-page-tab');
    spi.composer.find('.active-page').removeClass('active-page');
    current_page = controls.find('.active-page-tab').data('page-id');
    return spi.composer.find("[data-component-id='" + current_page + "']").find('.page-content').addClass('active-page').find('.column:first').find('.column-container').addClass('active').end().find('.section-column:first').addClass('active');
  };
  append_new_page_control = function(title, page_id) {
    var content, default_buttons, delete_button, delete_page, edit_buttons, new_indicator, page_tab, page_title, sync_input, title_input, toggle_buttons;
    new_indicator = $(options.indicator_template);
    indicators.append(new_indicator);
    new_indicator.attr('title', title).attr('data-page-id', page_id).tooltip(options.tooltip);
    page_tab = $(options.template);
    controls.append(page_tab);
    delete_button = $('.remove-page', page_tab);
    title_input = $('.edit-title', page_tab);
    default_buttons = $('.default-mode', page_tab);
    edit_buttons = $('.edit-mode', page_tab);
    page_title = '';
    sync_input = function() {
      title = title_input.val().trim();
      if (title === '') {
        title = 'blank';
      }
      title_input.prev('.title').text(title);
      $('.page-list-indicator').find("[data-page-id='" + page_id + "']").attr('data-original-title', title);
      return title;
    };
    toggle_buttons = function() {
      edit_buttons.toggleClass('hide');
      default_buttons.toggleClass('hide');
      return title_input.toggleClass('hide').prev('.title').toggleClass('hide');
    };
    delete_page = function() {
      var current, sort_page_id;
      sort_page_id = page_tab.attr('data-page-id');
      page_tab = $("[data-page-id='" + sort_page_id + "']");
      current = page_tab.next('li').length === 0 ? page_tab.prev('li') : page_tab.next('li');
      highlight_page("[data-page-id='" + (current.attr("data-page-id")) + "']");
      page_tab.remove();
      return $("[data-component-id='" + sort_page_id + "']").remove();
    };
    $('.edit-title', page_tab).on('keypress', function(e) {
      if (e.which === 13) {
        return $('.save-edit', page_tab).click();
      }
    });
    $('.edit-page', page_tab).on('click', function() {
      $('.edit-mode').not('.hide').find('.cancel-edit').click();
      page_title = $('.title', page_tab).text().trim();
      toggle_buttons();
      return title_input.val(page_title).trigger('focus');
    });
    $('.save-edit', page_tab).on('click', function() {
      page_title = sync_input();
      toggle_buttons();
      return spi.composer.find("[data-component-id='" + page_id + "'] > input[name='title']").val(page_title);
    });
    $('.cancel-edit', page_tab).on('click', function() {
      return toggle_buttons();
    });
    content = '<div>\
                <span class="content">Are you sure?</span>\
                <a class="btn button delete-page" class="btn save">Delete</a>\
               </div>';
    delete_button.popover({
      html: true,
      container: page_tab,
      trigger: 'manual',
      title: '',
      content: function() {
        return content;
      },
      placement: 'right'
    });
    delete_button.click(function() {
      if ($(".page-list .page-order-list").children().length > 1) {
        return $(this).popover('toggle');
      }
    });
    $('.showcase-editor.composer').on('document-click', function(e, target) {
      var target_button, target_popover;
      target_popover = $(target).closest('.popover');
      target_button = $(target).closest('.remove-page');
      if (target_popover.length === 0 && (target_button.length === 0 || target_button[0] !== delete_button[0])) {
        return delete_button.popover('hide');
      }
    });
    page_tab.on('click', '.delete-page', function(e) {
      delete_button.popover('destroy');
      delete_page();
      return $('.page-list-container').trigger('mouseleave');
    });
    return page_tab.attr('data-page-id', page_id).find('.title').text(title);
  };
  return {
    extensionPoints: $.noop,
    extensions: function() {
      spi.composer.on('honegger.syncPages', function() {
        build_page_control_by_page_order();
        return highlight_page('li:first');
      });
      return spi.composer.on('honegger.appendNewPage', function() {
        var page, page_id, title;
        page = spi.composer.find('[data-component-type="page"]:last');
        title = page.find('[name="title"]').val();
        page_id = page.data('component-id');
        append_new_page_control(title, page_id);
        highlight_page('li:last');
        return assign_page_order();
      });
    },
    initialize: function() {
      return initEvents();
    }
  };
};

window.PageRepo = function(api, spi) {
  var content, template;
  template = {};
  content = {};
  return {
    extensionPoints: function() {
      api.insertPage = function(name) {
        if (template[name]) {
          spi.insertComponent(spi.composer, 'page', {
            template: template[name]
          }, content[name]);
          return spi.composer.trigger('honegger.appendNewPage');
        }
      };
      api.addNewPage = function(name, page_template, page_content) {
        template[name] = page_template;
        return content[name] = page_content;
      };
      return spi.pageList = function() {
        return Object.keys(template);
      };
    },
    extensions: $.noop,
    initialize: $.noop
  };
};

$.fn.honegger.page = function(options) {
  var construct_column, construct_page, removeControls;
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
    $('.active', page).each(function() {
      return $(this).removeClass('active');
    });
    $('.column-container', page).each(function() {
      return $(this).remove();
    });
    return page;
  };
  construct_column = function(column_type, elements) {
    var children, column;
    column = options.spi.getColumn(column_type);
    children = column.find('.section-block').children();
    $.each(elements, function(index, components) {
      var name, _i, _len;
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        name = components[_i];
        options.spi.insertComponent($(children[index]).find('.components'), name);
      }
    });
    return column;
  };
  construct_page = function(config) {
    var template;
    template = $(options.template);
    $.each(config.template, function(_, column_config) {
      return $.each(column_config, function(column_type, elements) {
        return template.find('.sections').append(construct_column(column_type, elements));
      });
    });
    return template;
  };
  return {
    dataTemplate: {
      title: 'New Page',
      order: ''
    },
    editor: function(page, config, content) {
      page = page ? page.clone(true).prepend(options.content_template) : construct_page(config);
      options.spi.addColumnButton(page);
      return page;
    },
    control: function(page) {
      if (!page) {
        page = $('<div></div>');
      }
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
  template: '<div>' + '<input type="hidden" name="title" value="">' + '<input type="hidden" name="order" value="">' + '<div class="page-content layout-container">' + '<div class="sections"></div>' + '</div>' + '</div>',
  content_template: '<input type="hidden" name="title" value="">' + '<input type="hidden" name="order" value="">'
};

window.Page = function(api, spi) {
  return {
    extensionPoints: $.noop,
    extensions: $.noop,
    initialize: function() {
      return spi.installComponent('page', $.fn.honegger.page({
        spi: spi
      }));
    }
  };
};

window.Theme = function(api, spi) {
  var highlight_theme, initEvents, init_themes_list;
  highlight_theme = function(selected_theme) {
    $(".showcase-themes-wrapper div.theme").removeClass('active');
    return $(".showcase-themes-wrapper div[data-theme=" + selected_theme + "]").addClass('active');
  };
  init_themes_list = function(selected_theme) {
    $('.showcase-themes-wrapper').slideDown({
      duration: 300,
      complete: function() {
        return $('.themes-wrapper .slider').slick({
          dots: true,
          infinite: false,
          speed: 300,
          slidesToShow: 6,
          slidesToScroll: 6,
          responsive: [
            {
              breakpoint: 1490,
              settings: {
                slidesToShow: 5,
                slidesToScroll: 5,
                infinite: true,
                dots: true
              }
            }, {
              breakpoint: 1190,
              settings: {
                slidesToShow: 4,
                slidesToScroll: 4,
                infinite: true,
                dots: true
              }
            }, {
              breakpoint: 960,
              settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
                infinite: true,
                dots: true
              }
            }
          ]
        });
      }
    });
    if (selected_theme.length === 0) {
      selected_theme = 'rainbow';
    }
    return highlight_theme(selected_theme);
  };
  initEvents = function() {
    var iframe, preview_modal;
    $('.themes-wrapper .save').on('click', function() {
      var iframe, theme_type;
      iframe = $('.theme-preview-modal #theme-frame');
      theme_type = iframe[0].src.replace(/.*?\//ig, '');
      spi.composer.trigger('chooseTheme', theme_type);
      $('.themes-wrapper').slideUp({
        duration: 300
      });
      return $('.theme-preview-modal').modal('hide');
    });
    $('.themes-wrapper .cancel').on('click', function() {
      $('.themes-wrapper').slideUp({
        duration: 300
      });
      $('.theme-preview-modal').modal('hide');
      return spi.composer.trigger('closeThemeModal');
    });
    preview_modal = $('.theme-preview-modal');
    iframe = preview_modal.find('#theme-frame');
    $('*[data-theme]').on('click', function(e) {
      var target, theme_type;
      target = $(e.currentTarget);
      theme_type = target.attr('data-theme');
      highlight_theme(theme_type);
      preview_modal.removeClass('showcase-preview').addClass('theme-preview');
      return iframe[0].src = "themes/" + theme_type + '.html';
    });
    iframe.load(function(e) {
      return spi.composer.trigger('loadTheme', e.target.src.replace(/.*themes\//ig, ''));
    });
    return $('.composer .theme-button').on('click', function() {
      return init_themes_list('rainbow');
    });
  };
  return {
    extensionPoints: $.noop,
    extensions: $.noop,
    initialize: initEvents
  };
};
