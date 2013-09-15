(($, document, window) ->
  Honegger = (element, options) ->
    self = this
    composer = $(element)
    components = {}

    disabled = false
    mode = 'edit'
    componentIds = {}

    composer.data('honegger', this)
    composer.addClass('honegger-composer')

    toolbar = if typeof options.toolbar == 'string' then $(options.toolbar) else options.toolbar

    insideComposer = (range) ->
      $.inArray(element, $(range.startContainer).parents()) != -1

    notInsideComponent = (range) ->
      $(range.startContainer).parents(options.componentSelector).length == 0

    currentRange = ->
      selection = window.getSelection()
      if selection.rangeCount
        range = selection.getRangeAt(0)
        return range if insideComposer(range) && notInsideComponent(range)

    generateId = (type) ->
      componentIds[type] = 1 unless componentIds[type]?
      componentIds[type] = componentIds[type] + 1 while $("[data-component-id='#{type}-#{componentIds[type]}']").length != 0
      "#{type}-#{componentIds[type]}"

    execCommand = (command, args)->
      if args? then document.execCommand(command, false, args) else document.execCommand(command)

    bindHotkey = (target, key, command) ->
      target.keydown(key,(e)->
        if target.attr('contenteditable') && target.is(':visible')
          e.preventDefault()
          e.stopPropagation()
          execCommand(command) if !disabled && currentRange()?
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

    disable = (editable) ->
      disabled = true
      editable.attr('contenteditable', 'false')

    enable = (editable) ->
      disabled = false
      editable.attr('contenteditable', 'true')

    changeMode = (element, handler) ->
      config = element.data('component-config') || {}
      type = element.data('component-type')
      $(options.configurationSelector, element).each ->
        config[$(this).attr(options.configuration)] = $(this).val()
      component = components[element.data('component-type')]
      element.replaceWith(handler(component, config).data('component-config', config)
        .attr('data-component-type', type).attr('data-role', 'component')
        .attr('data-component-id', element.data('component-id')))

    editMode = (element) ->
      changeMode element, (component, config) ->
        editor = component.editor(options.componentEditorTemplate, config)
        $(options.configurationSelector, editor).each ->
          configElement = $(this)
          configElement.val(config[configElement.attr(options.configuration)]) if configElement.attr(options.configuration)?
        editor

    previewMode = (element) ->
      changeMode element, (component) ->
        component.control()

    init = ->
      if options.multipleSections then makeComposers(composer) else makeComposer(composer)

    this.execCommand = (command, args) ->
      execCommand(command, args) if !disabled && currentRange()?

    this.insertComponent = (name) ->
      return unless disabled || components[name]?
      range = currentRange()
      return unless range?
      editor = components[name].editor(options.componentEditorTemplate, {})
      editor.data('component-config', {})
      .attr('data-component-type', name)
      .attr('data-role', 'component')
      .attr('data-component-id', generateId(name))

      range.insertNode(editor[0])

    this.installComponent = (name, component) ->
      components[name] = component

    this.changeMode = (new_mode) ->
      mode = new_mode
      if mode == 'edit'
        self.enable()
        composer.find(options.componentSelector).each ->
          editMode($(this))
      else
        self.disable()
        composer.find(options.componentSelector).each ->
          previewMode($(this))

    this.getTemplate = (handler) ->
      template = composer.clone()
      template.find(options.editableSelector).removeAttr('contenteditable')
      template.find(options.componentSelector).each ->
        component = $(this)
        placeholder = $(options.componentPlaceholder)
        placeholder.attr('data-component-type', component.data('component-type'))
        .attr('data-role', 'component').attr('data-component-id', component.data('component-id'))
        component.replaceWith(placeholder)
      handler(template.html())

    this.loadContent = (content, mode) ->
      composer.html(content)
      init()
      self.changeMode(mode)

    if (options.multipleSections)
      this.insertSection = (template) ->
        composer.append(makeComposers($(template))) unless disabled
      this.disable = ->
        disable(composer.find(options.editableSelector))
      this.enable = ->
        enable(composer.find(options.editableSelector))
    else
      this.disable = ->
        disable(composer)
      this.enable = ->
        enable(composer)

    init()
    $.fn.honegger.initToolbar composer, toolbar, options

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
    componentSelector: '*[data-role="component"]'
    configurationSelector: 'input[data-component-config-key]'
    configuration: 'data-component-config-key'
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
      'tab': 'indent'
    componentEditorTemplate: '<table contenteditable="false">' +
    '<thead><tr><td class="component-header"></td></tr></thead>' +
    '<tbody><tr><td class="component-content"></td></tr></tbody>' + '</table>'
    componentPlaceholder: '<div></div>')(jQuery, document, window)


