(($, document) ->
  $.fn.honegger = ->


  $.fn.honegger.defaults =
    multipleSections: true
    editable_selectors: '.section'
    toolbar_selector: '*[data-role="toolbar"]'
    toolbar_button_selector: '*[data-command]'
    toolbar_button_command: 'data-command'
    toolbar_button_active_class: 'on'
    hotkeys:
      'ctrl+b meta+b': 'bold',
      'ctrl+i meta+i': 'italic',
      'ctrl+u meta+u': 'underline',
      'ctrl+z meta+z': 'undo',
      'ctrl+y meta+y meta+shift+z': 'redo',
      'shift+tab': 'outdent',
      'tab': 'indent')(jQuery, document)

