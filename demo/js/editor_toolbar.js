(function ($) {
  var element = $('.text-editor-toolbar');
  var execCommand, initToolbar, options, toolbarCommandValues, updateToolbar;
  toolbarCommandValues = [];
  options = {
    buttons: '[data-command]',
    buttonsFont: '[data-font]',
    buttonCommand: 'data-command',
    buttonCommandArgument: 'data-command-argument',
    buttonHighlight: 'btn-primary'
  };
  execCommand = function(command, args) {
    document.execCommand("styleWithCSS", false, true);
    if (args) {
      document.execCommand(command, false, args);
    } else {
      document.execCommand(command);
    }
  };
  updateToolbar = function() {
    var backColor, fontName, fontSize, foreColor;
    $(options.buttons, element).each(function() {
      var button, command;
      button = $(this);
      command = button.attr(options.buttonCommand);
      if (document.queryCommandState(command)) {
        button.addClass(options.buttonHighlight);
      } else {
        button.removeClass(options.buttonHighlight);
      }
    });
    $('*[' + options.buttonCommandArgument + ']', element).each(function(idx, item) {
      var commandValue;
      commandValue = $(item).attr(options.buttonCommandArgument);
      if (commandValue) {
        return toolbarCommandValues.push(commandValue);
      }
    });
    fontName = document.queryCommandValue('fontName');
    fontSize = document.queryCommandValue('fontSize');
    foreColor = document.queryCommandValue('foreColor');
    backColor = document.queryCommandValue('backColor');
    if (fontName && toolbarCommandValues.indexOf(fontName.replace(/'/ig, '')) === -1) {
      return;
    }
    $(options.buttonsFont, element).each(function(idx) {
      var button, grayLevel, icon, iconElement, rgb, value;
      button = $(this);
      icon = button.find('i');
      if (fontName && idx === 0) {
        icon.attr('data-setting', fontName.replace(/\'/ig, ''));
      }
      if (fontSize && typeof fontSize !== 'undefined' && idx === 1) {
        value = 'smaller';
        switch (fontSize) {
          case '2':
            value = 'smaller';
            break;
          case '3':
            value = 'small';
            break;
          case '4':
            value = 'medium';
            break;
          case '5':
            value = 'large';
            break;
          case '6':
            value = 'larger';
        }
        icon.attr('data-setting', value);
      }
      if (foreColor && idx === 2) {
        icon.css('color', foreColor);
      }
      if (backColor && backColor !== 'transparent' && idx === 3) {
        rgb = backColor.replace(/[a-z\(\)]+/ig, '').split(',');
        grayLevel = rgb[0].trim() * 0.299 + rgb[1].trim() * 0.587 + rgb[2].trim() * 0.114;
        if (grayLevel !== '' && grayLevel !== null && typeof grayLevel !== 'undefined') {
          if (grayLevel >= 192) {
            icon.css('color', '#000');
          } else {
            icon.css('color', '#fff');
          }
        }
        iconElement = button.find('.icon-font-backcolor');
        return iconElement.css('backgroundColor', backColor);
      }
    });
  };
  initToolbar = function() {
    return $(options.buttons, element).each(function() {
      var button;
      button = $(this);
      return button.click(function() {
        execCommand(button.attr(options.buttonCommand), button.attr(options.buttonCommandArgument));
        return updateToolbar();
      });
    });
  };
  $('article.page-content-container').on('mouseup keyup focus', '.component div[contenteditable="true"]', function() {
    updateToolbar();
  });
  initToolbar();
})(jQuery);