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
        configElement = $(this)
        key = configElement.attr(options.configuration)
        if key.indexOf('.') != -1
          struct = config
          for field in key.split('.')
            struct[field] = {} unless struct[field]?
            struct = struct[field]
          eval("config.#{key} = getConfigElementValue(configElement)")
        else
          config[key] = getConfigElementValue(configElement)
      config

    getConfigElementValue = (configElement) ->
      if configElement.attr('type') == 'checkbox' then configElement.is(':checked') else configElement.val();

    setConfigElementValue = (configElement, value) ->
      if configElement.attr('type') == 'checkbox' then configElement.prop('checked', value == 'true') else configElement.val(value)

    setConfiguration = (editor, config) ->
      $(options.configurationSelector, editor).each ->
        configElement = $(this)
        key = configElement.attr(options.configuration)
        value = if key.indexOf('.') != -1 then eval("config.#{key}") else config[key]
        setConfigElementValue(configElement, value) if value?
      editor

    config = (target, id, type, config) ->
      target.data('component-config', config)
      .attr('data-component-type', type).attr('data-role', 'component')
      .attr('data-component-id', id)

    changeMode = (element, handler) ->
      configuration = getConfiguration(element)
      element.replaceWith(config(handler(components[element.data('component-type')], configuration),
        element.data('component-id'), element.data('component-type'), configuration))

    install: (name, component) ->
      components[name] = component
    newComponent: (name, component_config) ->
      component_id = generateId(name)
      component_config = $.extend(true, {component_id: component_id}, component_config)
      setConfiguration(config(components[name].editor(options.componentEditorTemplate, component_config),
        component_id, name,
        component_config), component_config)
    modes:
      edit: (element, config) ->
        changeMode element, (component, config) ->
          setConfiguration(component.editor(options.componentEditorTemplate, config), config)
      control: (element, config) ->
        changeMode element, (component) ->
          component.control(config[element.data('component-id')])
    setConfiguration: (configuration)->
      $(options.componentSelector, composer).each ->
        component = $(this)
        component.data('component-config', configuration[component.data('component-id')])
    getTemplate: (template, handler)->
      dataTemplate = {}
      configurations = {}
      template.find(options.componentSelector).each ->
        component = $(this)
        id = component.data('component-id')
        type = component.data('component-type')
        dataTemplate[id] = $.extend(true, {}, components[type].dataTemplate)
        configurations[id] = getConfiguration(component)
      page = template.clone()
      page.find(options.editableSelector).removeAttr('contenteditable')
      page.find(options.componentSelector).each ->
        component = $(this)
        id = component.data('component-id')
        type = component.data('component-type')
        component.replaceWith(config($(options.componentPlaceholder), id, type, {}))
      handler(page.html(), dataTemplate, configurations)
    get: (name) ->
      components[name])(jQuery)