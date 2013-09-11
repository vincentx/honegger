(($, document, window) ->
  Honegger = (element, options) ->
    composer = $(element)

    disable = false

    composer.data('honegger', this)
    composer.addClass('honegger-composer')

    toolbar = if typeof options.toolbar == 'string' then $(options.toolbar) else options.toolbar

    $.fn.honegger.initToolbar composer, toolbar, options

    currentRange = ->
      selection = window.getSelection()
      if selection.getRangeAt? && selection.rangeCount
        range = selection.getRangeAt(0)
        return range if $.inArray(element, $(range.startContainer).parents()) != -1

    execCommand = (command, args)->
      if args? then document.execCommand(command, false, args) else document.execCommand(command)

    bindHotkey = (target, key, command) ->
      target.keydown(key,(e)->
        if target.attr('contenteditable') && target.is(':visible')
          e.preventDefault()
          e.stopPropagation()
          execCommand(command) unless disable
      ).keyup(key, (e) ->
        if target.attr('contenteditable') && target.is(':visible')
          e.preventDefault()
          e.stopPropagation()
      )

    makeComposer = (element)->
      element.attr('contenteditable', 'true').on 'mouseup keyup mouseout focus', ->
        $.fn.honegger.updateToolbar(toolbar, options)
      for key, command of options.hotkeys
        bindHotkey(element, key, command)

    makeComposers = (element) ->
      element.find(options.editableSelector).andSelf().filter(options.editableSelector).each ->
        makeComposer($(this))
      element

    this.execCommand = (command, args) ->
      execCommand(command, args) if !disable && currentRange()?

    if (options.multipleSections)
      this.insertSection = (template) ->
        composer.append(makeComposers($(template))) unless disable
      this.disable = ->
        disable = true
        composer.find(options.editableSelector).attr('contenteditable', 'false')
      this.enable = ->
        disable = false
        composer.find(options.editableSelector).attr('contenteditable', 'true')
      makeComposers(composer)
    else
      this.disable = ->
        disable = true
        composer.attr('contenteditable', 'false')
      this.enable = ->
        disable = false
        composer.attr('contenteditable', 'true')
      makeComposer(composer)

  $.fn.honegger = (options)->
    parameters = $.makeArray(arguments).slice(1)
    this.each ->
      instance = $.data(this, 'honegger')
      return new Honegger(this, $.extend({}, $.fn.honegger.defaults, options)) unless instance
      instance[options].apply(instance, parameters) if typeof(options) == 'string' && instance[options]?

  $.fn.honegger.initToolbar = (composer, toolbar, options) ->
    $(options.buttons, toolbar).each ->
      button = $(this)
      button.click ->
        composer.honegger('execCommand', button.attr(options.buttonCommand))

  $.fn.honegger.updateToolbar = (toolbar, options)->
    $(options.buttons, toolbar).each ->
      button = $(this)
      command = button.attr(options.buttonCommand)
      if document.queryCommandState(command)
        button.addClass(options.buttonHighlight)
      else
        button.removeClass(options.buttonHighlight)

  $.fn.honegger.defaults =
    multipleSections: true
    editableSelector: '*[data-role="composer"]'
    toolbar: '*[data-role="toolbar"]'
    buttons: '*[data-command]'
    buttonCommand: 'data-command'
    buttonHighlight: 'honegger-button-active'
    hotkeys:
      'ctrl+b meta+b': 'bold',
      'ctrl+i meta+i': 'italic',
      'ctrl+u meta+u': 'underline',
      'ctrl+z meta+z': 'undo',
      'ctrl+y meta+y meta+shift+z': 'redo',
      'shift+tab': 'outdent',
      'tab': 'indent')(jQuery, document, window)

