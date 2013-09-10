(($, document, window) ->
  Honegger = (element, options) ->
    self = this
    composer = $(element)

    composer.data('honegger', self)
    composer.addClass('honegger-composer')

    currentRange = ->
      selection = window.getSelection()
      if selection.getRangeAt? && selection.rangeCount
        range = selection.getRangeAt(0)
        return range if $.inArray(element, $(range.startContainer).parents()) != -1

    bindHotkey = (target, key, command) ->
      target.keydown(key,(e)->
        if target.attr('contenteditable') && target.is(':visible')
          e.preventDefault()
          e.stopPropagation()
          self.execCommand(command)
      ).keyup(key, (e) ->
        if target.attr('contenteditable') && target.is(':visible')
          e.preventDefault()
          e.stopPropagation()
      )

    makeComposer = (element)->
      element.attr('contenteditable', 'true').on('mouseup keyup mouseout focus', ->

      )
      for key, command of options.hotkeys
        bindHotkey(element, key, command)

    makeComposers = (element) ->
      element.find(options.editableSelector).andSelf().filter(options.editableSelector).each ->
        makeComposer($(this))
      element

    self.execCommand = (command) ->
      document.execCommand(command) if currentRange()?

    if (options.multipleSections)
      self.insertSection = (template) ->
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

