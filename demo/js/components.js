window.Components = {
  'resource-multimedia': {
    editor: function (component, config, content) {
      var target = $('<div class=\"component resource-multimedia\" cm-resource-multimedia-editable cm-delete-component cm-draggable-component>\n   <div class=\"view shown\">\n    <span class=\"placeholder\">\n      <i class=\"icon icon-picture\"><\/i>\n      <span>Click here to upload Image/Youtube<\/span>\n    <\/span>\n   <\/div>\n   <div class=\"operation-bar\">\n       <a class=\"edit-component\"><i class=\"icon icon-pencil-1\"><\/i><\/a>\n       <a class=\"move-component\"><i class=\"icon icon-move-3\"><\/i><\/a>\n       <a class=\"delete-component\"><i class=\"icon icon-trash\"><\/i><\/a>\n   <\/div>\n   <input id=\"resource-component-content\" type=\"hidden\" name=\"content\">\n   <input type=\"hidden\" data-component-config-type=\"json\" data-component-config-key=\"permissions\">\n <div>');
      target.data('component-config', config).data('component-content', content);
      return target;
    },
    dataTemplate: {"content": ""},
    control: function (component, config, content) {
      var control;
      control = $('<div class=\"component resource-multimedia\" cm-resource-multimedia-visible>\n  <div class=\"view shown\"><div>\n<div>\n');
      control.attr('data-role', 'component').data('component-config', config).data('component-content', content);
      return control;
    }
  },
  'resource-text': {
    editor: function (component, config, content) {
      var target = $('<div class=\"component resource-text\" cm-resource-text-editable cm-delete-component cm-draggable-component>\n   <div class=\"view shown\"><span class=\"placeholder\">Text: click here to edit<\/span><\/div>\n   <div class=\"edit\" contenteditable=\"false\"><\/div>\n   <div class=\"operation-bar\">\n       <a class=\"edit-component\"><i class=\"icon icon-pencil-1\"><\/i><\/a>\n       <a class=\"move-component\"><i class=\"icon icon-move-3\"><\/i><\/a>\n       <a class=\"delete-component\"><i class=\"icon icon-trash\"><\/i><\/a>\n   <\/div>\n   <input type=\"hidden\" name=\"content\">\n   <input type=\"hidden\" data-component-config-type=\"json\" data-component-config-key=\"permissions\">\n<\/div>');
      target.data('component-config', config).data('component-content', content);
      return target;
    },
    dataTemplate: {"content": ""},
    control: function (component, config, content) {
      var control;
      control = $('<div class=\"component resource-text\" cm-resource-text-visible>\n  <div class=\"view shown\" ng-bind-html=\"text_content\"><\/div>\n<\/div>\n');
      control.attr('data-role', 'component').data('component-config', config).data('component-content', content);
      return control;
    }
  }
};