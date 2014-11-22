(function ($) {
  var original_scrolltop = 0;
  var is_click = false;
  var page_info = [];

  var add_portfolio_title = function (page_array, title) {
    var first_page = $(page_array[0]);
    page_array[0] = first_page.prepend("<h2>" + title + "</h2>")[0].outerHTML;
    return page_array;
  };

  var get_theme_template = function (page_templates, page_data, portfolio_title) {
    var list_array, page_array;
    list_array = [];
    page_array = [];
    _.each(page_data, function (component, component_id) {
      var list_item, new_id, page_item, page_order;
      if (component.type === 'page') {
        page_order = Math.round(component.order);
        new_id = 'page' + (page_order + 1);
        list_item = $('<li><a class="title">' + component.title + '</a><span></span></li>');
        list_item.attr('id', component_id.replace(/-/ig, ''));
        list_array[page_order] = list_item[0].outerHTML;
        page_item = $(_.filter(page_templates, function (item) {
          return $(item).data('component-id') === component_id;
        }));
        page_item.css('min-height', $('body').height()).attr('id', new_id);
        return page_array[page_order] = page_item[0].outerHTML;
      }
    });
    page_array = add_portfolio_title(_.compact(page_array), portfolio_title);

    return {
      'content': _.compact(page_array).join(''),
      'list': _.compact(list_array).join('')
    };
  };

  var active_page_list = function (page_list_item) {
    return page_list_item.addClass('active');
  };

  var reset_theme = function () {
    $('.page-list').empty();
    return $('.content-list').empty();
  };

  var init_events = function () {
    var indicate_current_index, trigger_current_page, update_position;
    $('.page-list').on('click', 'a', function (e) {
      var index, li, target, top;
      target = $(e.currentTarget);
      li = target.parent();
      if (li.hasClass('active')) {
        return;
      }
      is_click = true;
      index = li.index('.page-list li') + 1;
      top = $(".content-list > div:nth-child(" + index + ")").position().top;
      $('li', '.page-list').removeClass('active');
      li.addClass('active');
      $('#portfolio-editor').animate({
        scrollTop: top
      }, {
        duration: 300,
        complete: function () {
          is_click = false;
          return original_scrolltop = $('#portfolio-editor').scrollTop();
        }
      });
    });

    trigger_current_page = function (scroll_down, scrollTop, offsetY, index) {
      var view_height;
      view_height = $('div#page' + (index + 1)).height();
      if (scroll_down) {
        if (scrollTop - offsetY > view_height / 2) {
          return $('a', $('.page-list li')[index + 1]).click();
        }
      } else {
        if (page_info[index + 1] - scrollTop > view_height / 2) {
          return $('a', $('.page-list li')[index]).click();
        }
      }
    };

    indicate_current_index = function (scrollTop, scroll_down) {
      return _.each(page_info, function (offsetY, index) {
        if (scrollTop > offsetY && scrollTop < page_info[index + 1]) {
          return trigger_current_page(scroll_down, scrollTop, offsetY, index);
        }
      });
    };

    update_position = function () {
      var pages, scrollTop, scroll_down;
      if (is_click) {
        return;
      }
      scrollTop = $('#portfolio-editor').scrollTop();
      pages = $('li', $('.page_list'));
      if (scrollTop === 0) {
        pages.removeClass('active');
        $(pages[0]).addClass('active');
        return original_scrolltop = 0;
      } else {
        scroll_down = original_scrolltop < scrollTop;
        return indicate_current_index(scrollTop, scroll_down);
      }
    };
    return $('#portfolio-editor').on('scroll', function () {
      return update_position();
    });
  };

  var decode = function (string) {
    return $('<textarea/>').html(string).val()
  };

  var set_config = function (config, component_id) {
    config.prefix = "content[#{component_id}]";
    config.component_id = component_id;
    if (config.label) {
      config.label = decode(config.label);
    }
    return config;
  };

  var enhance_components = function (editor, data) {
    $('[data-role="component"][data-component-type!="page"]', editor).each(function (index, element) {
      var component, component_id, config, content, control;
      component = $(element);
      component_id = component.attr('data-component-id');
      if (component_id) {
        config = set_config(data.config[component_id], component_id);
        content = data.content[component_id];
        control = HoneggerComponents[config.type].control(null, config, content);
        return component.replaceWith(control);
      }
    });
  };

  $('.theme-container').on('initTheme', function (e, data) {
    var theme_templates;
    theme_templates = get_theme_template($(data.template), data.content, data.title || 'Blank Title');
    var content_list = $('.theme-container .content-list');
    content_list.html(theme_templates['content']);
    $('.theme-container .page-list').html(theme_templates['list']);
    enhance_components(content_list, data);
    init_events();
    page_info = _.map($('[data-component-type="page"]'), function (page) {
      return $(page).position().top;
    });
    $('.theme-container').closest('body').find('.loading-backdrop').hide();
    active_page_list($('.theme-container .page-list > li:first-child'));
  });
})(jQuery);