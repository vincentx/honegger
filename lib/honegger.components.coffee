(($) ->
  $.fn.honegger.components = (composer, options) ->
    components = {}
    componentIds = {}

    generateId = (type) ->
      componentIds[type] = 1 unless componentIds[type]?
      componentIds[type] = componentIds[type] + 1 while $("[data-component-id='#{type}-#{componentIds[type]}']",
        composer).length != 0
      "#{type}-#{componentIds[type]}"

    getConfiguration = (element) ->
      config = element.data('component-config') || {}
      $(options.configurationSelector, element).each ->
        config[$(this).attr(options.configuration)] = $(this).val()
      config

    setConfiguration = (editor, config) ->
      $(options.configurationSelector, editor).each ->
        configElement = $(this)
        configElement.val(config[configElement.attr(options.configuration)]) if configElement.attr(options.configuration)?
      editor

    config = (target, id, type, config) ->
      target.data('component-config', config)
      .attr('data-component-type', type).attr('data-role', 'component')
      .attr('data-component-id', id)

    changeMode = (element, handler) ->
      configuration = getConfiguration(element)
      element.replaceWith(config(handler(components[element.data('component-type')], configuration),
        element.data('component-id'), element.data('component-type'), config))

    install: (name, component) ->
      components[name] = component
    newComponent: (name) ->
      config(components[name].editor(options.componentEditorTemplate, {}), generateId(name), name, {})
    modes:
      edit: (element) ->
        changeMode element, (component, config) ->
          setConfiguration(component.editor(options.componentEditorTemplate, config), config)
      control: (element) ->
        changeMode element, (component) ->
          component.control()

    getTemplate: (template, handler)->
      dataTemplate = {}
      configurations = {}
      template.find(options.componentSelector).each ->
        component = $(this)
        id = component.data('component-id')
        type = component.data('component-type')
        dataTemplate[id] = $.extend(true, {}, components[type].dataTemplate)
        configurations[id] = getConfiguration(component)
        component.replaceWith(config($(options.componentPlaceholder), id, type, {}))
      handler(dataTemplate, configurations)

    get: (name) ->
      components[name])(jQuery)