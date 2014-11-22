function isChrome() {
  return navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
}

function isFirefox() {
  return navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
}

function isSafari() {
  return navigator.userAgent.toLowerCase().indexOf("safari") > -1 && navigator.userAgent.indexOf('Chrome') == -1;
}

function encode(string){
  return $("<textarea/>").html(string).html();
}

function text_editable(element, config, content){
  var edit, toolbar, value, view;
  view = element.find('.view');
  edit = element.find('.edit');
  if (content.content && content.content.trim()) {
    value = content.content;
    view.html(value);
    edit.html(value);
  }
  toolbar = $('.text-editor-toolbar');

  var changeMode = function(edit_mode) {
    var edit_area, offset;
    element.toggleClass('edit-mode');
    element.find('.view,.edit').toggleClass('shown');
    if (edit_mode) {
      edit_area = element.find('.edit');
      edit_area.attr('contenteditable', 'true').focus();
      offset = edit_area.offset();
      toolbar.show(0, function() {
        toolbar.offset({
          top: offset.top - 25,
          left: offset.left
        });
        return toolbar.css('opacity', 1);
      });
    } else {
      element.find('.edit').attr('contenteditable', 'false');
      return toolbar.hide().css('opacity', 0);
    }
  };

  var setContent = function(target, content) {
    var content_input;
    view = element.find('.view');
    content_input = element.find('input[name="content"]');
    if (content !== '') {
      view.html(content);
      return content_input.val(content.trim());
    } else {
      view.html('<span class="placeholder">Text: click here to edit</span>');
      target.empty();
      return content_input.val('');
    }
  };

  var lost_focus = function() {
    var target;
    view = element.find('.view');
    target = $('div.edit[contentEditable="true"]', element);
    if (target.length === 0) {
      return;
    }
    content = target.html();
    changeMode(false);
    setContent(target, content.trim());
  };
  if (isChrome() === false) {
    $('div.composer').on('document-click', function(e, target) {
      var component, text_toolbar;
      component = $(target).closest('.component.resource-text');
      text_toolbar = $(target).closest('.text-editor-toolbar');
      if ($(target).closest('.delete-component').length > 0 && component[0] === element[0]) {
        return;
      }
      if (text_toolbar.length === 0) {
        if (component.length === 0 || element[0] !== component[0]) {
          lost_focus();
        }
        if (element[0] === component[0]) {
          if (isFirefox()) {
            if (toolbar.is(':visible')) {
              return;
            }
            changeMode(true);
          } else if (isSafari()) {
            return setTimeout(function() {
              if (toolbar.is(':visible')) {
                return;
              }
              return changeMode(true);
            }, 10);
          }
        }
      }
    });
  } else {
    element.find('.view,.edit-component').click(function() {
      changeMode(true);
    });
    element.find('div.edit[contentEditable]').blur(function(e) {
      e.preventDefault();
      if ($(e.relatedTarget).closest('.text-editor-toolbar').length > 0) {
        return;
      }
      lost_focus();
    });
  }
}

function text_visible(element, config, content){
  if (content.content && content.content.trim()) {
    content = content.content;
    element.find('.view').html(content)
  }
}

function title_editable(element, config, content) {
  var changeMode, edit, setView, sync_view, view;
  view = element.find('.view');
  edit = element.find('.edit input');
  if (content.content && content.content.trim()) {
    content = encode(content.content).replace(/[ ]/ig, '&nbsp;');
    view.html(content);
    edit.val(content);
  }
  changeMode = function(edit_mode) {
    element.toggleClass('edit-mode');
    element.find('.view,.edit').toggleClass('shown');
    if (edit_mode) {
      return element.find('.edit input').focus();
    }
  };
  setView = function(target, content) {
    view = element.find('.view');
    if (content !== '') {
      return view.html(content);
    } else {
      view.html('<span class="placeholder">Title: click here to edit</span>');
      return target.val('');
    }
  };
  element.find('.view,.edit-component').click(function() {
    return changeMode(true);
  });
  sync_view = function(target) {
    content = target.val();
    changeMode(false);
    return setView(target, encode(content.trim()).replace(/[ ]/ig, '&nbsp;'));
  };
  return element.find('.edit input').blur(function(e) {
    return sync_view($(e.target));
  });
}

function title_visible(element, config, content) {
  if (content.content && content.content.trim()) {
    element.find('.view').text(content.content)
  }
}

window.HoneggerComponents = {
  'resource-multimedia': {
    editor: function (component, config, content) {
      var target = $('<div class=\"component resource-multimedia\">\n   <div class=\"view shown\">\n    <span class=\"placeholder\">\n      <i class=\"icon icon-picture\"><\/i>\n      <span>Click here to upload Image/Youtube<\/span>\n    <\/span>\n   <\/div>\n   <div class=\"operation-bar\">\n       <a class=\"edit-component\"><i class=\"icon icon-pencil-1\"><\/i><\/a>\n       <a class=\"move-component\"><i class=\"icon icon-move-3\"><\/i><\/a>\n       <a class=\"delete-component\"><i class=\"icon icon-trash\"><\/i><\/a>\n   <\/div>\n   <input id=\"resource-component-content\" type=\"hidden\" name=\"content\">\n <div>');
      target.data('component-config', config).data('component-content', content);
      return target;
    },
    dataTemplate: {"content": ""},
    control: function (component, config, content) {
      var control = $('<div class=\"component resource-multimedia\">\n  <div class=\"view shown\"><div>\n<div>\n');
      control.attr('data-role', 'component').data('component-config', config).data('component-content', content);
      return control;
    }
  },
  'resource-text': {
    editor: function (component, config, content) {
      var target = $('<div class=\"component resource-text\">\n   <div class=\"view shown\"><span class=\"placeholder\">Text: click here to edit<\/span><\/div>\n   <div class=\"edit\" contenteditable=\"false\"><\/div>\n   <div class=\"operation-bar\">\n       <a class=\"edit-component\"><i class=\"icon icon-pencil-1\"><\/i><\/a>\n       <a class=\"move-component\"><i class=\"icon icon-move-3\"><\/i><\/a>\n       <a class=\"delete-component\"><i class=\"icon icon-trash\"><\/i><\/a>\n   <\/div>\n   <input type=\"hidden\" name=\"content\">\n\n<\/div>');
      text_editable(target, config, content);
      return target;
    },
    dataTemplate: {"content": ""},
    control: function (component, config, content) {
      var control = $('<div class=\"component resource-text\">\n  <div class=\"view shown\" ng-bind-html=\"text_content\"><\/div>\n<\/div>\n');
      text_visible(control, config, content);
      return control;
    }
  },
  'resource-title': {
    editor: function (component, config, content) {
      var target = $('<div class=\"component resource-title\">\n  <div class=\"view shown\"><span class=\"placeholder\">Title: click here to edit<\/span><\/div>\n  <div class=\"edit\">\n      <input type=\"text\" name=\"content\" maxlength=\"128\" value=\"\" placeholder=\"Title: click here to edit\">\n  <\/div>\n  <div class=\"operation-bar\">\n      <a class=\"edit-component\"><i class=\"icon icon-pencil-1\"><\/i><\/a>\n      <a class=\"move-component\"><i class=\"icon icon-move-3\"><\/i><\/a>\n      <a class=\"delete-component\"><i class=\"icon icon-trash\"><\/i><\/a>\n  <\/div>\n<\/div>');
      title_editable(target, config, content);
      return target;
    },
    dataTemplate: {"content":""},
    control: function (component, config, content) {
      var control = $('<div class=\"component resource-title\">\n  <div class=\"view shown\"><\/div>\n<div>\n');
      title_visible(control, config, content);
      return control;
    }
  }
};