(($, document, window) ->
  Honegger = (element, options) ->
    composer = $(element)

    composer.data('honegger', this)
    composer.addClass('has-honegger')

    currentRange = ->
      selection = window.getSelection()
      if selection.getRangeAt? && selection.rangeCount
        range = selection.getRangeAt(0)
        return range if $.inArray(element, $(range.startContainer).parents()) != -1

    makeComposer = (element)->
      element.attr('contenteditable', 'true').on('mouseup keyup mouseout focus', ->

      )

    makeComposers = (element) ->
      element.find(options.editableSelector).andSelf().filter(options.editableSelector).each ->
        makeComposer($(this))
      element

    this.execCommand = (command) ->
      document.execCommand(command) if currentRange()?

    if (options.multipleSections)
      this.insertSection = (template) ->
        composer.append(makeComposers($(template)))
      makeComposers(composer)
    else
      makeComposer(composer)

  $.fn.honegger = (options)->
    parameters = $.makeArray(arguments).slice(1)
    this.each ->
      instance = $.data(this, 'honegger')
      return new Honegger(this, $.extend({}, $.fn.honegger.defaults, options)) unless instance
      instance[options].apply(instance, parameters) if typeof(options) == 'string'

  $.fn.honegger.defaults =
    multipleSections: true
    editableSelector: '*[data-role="composer"]'
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

