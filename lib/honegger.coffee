(($, document, window) ->
  Honegger = (element, options) ->
    this.element = $(element)
    this.options = options

    this.element.data('honegger', this)
    this.element.addClass('has-honegger')

    currentRange = ->
      selection = window.getSelection()
      if selection.getRangeAt? && selection.rangeCount
        range = selection.getRangeAt(0)
        return range if $.inArray(element, $(range.startContainer).parents()) != -1

    this.execCommand = (command) ->

      document.execCommand(command) if currentRange()?

  $.fn.honegger = (options)->
    parameters = $.makeArray(arguments).slice(1)
    this.each ->
      instance = $.data(this, 'honegger')
      return new Honegger(this, options) unless instance
      instance[options].apply(instance, parameters) if typeof(options) == 'string'

  $.fn.honegger.defaults =
    multipleSections: true
    toolbar: '*[data-role="toolbar"]'
    buttons: '*[data-command]'
    hotkeys:
      'ctrl+b meta+b': 'bold',
      'ctrl+i meta+i': 'italic',
      'ctrl+u meta+u': 'underline',
      'ctrl+z meta+z': 'undo',
      'ctrl+y meta+y meta+shift+z': 'redo',
      'shift+tab': 'outdent',
      'tab': 'indent')(jQuery, document, window)

