(($) ->
  ComponentEditor = (->
    getConfigElementValue = (configElement) ->
      if configElement.attr('type') == 'checkbox' then configElement.is(':checked') else configElement.val();

    setConfigElementValue = (configElement, value) ->
      if configElement.attr('type') == 'checkbox' then configElement.prop('checked', value) else configElement.val(value)

    ensure = (config, key) ->
      struct = config
      for field in key.split('.')
        struct[field] = {} unless struct[field]?
        struct = struct[field]

    getConfiguration: (editor) ->
      config = editor.data('component-config') || {}
      $('*[data-component-config-key]', editor).each ->
        configElement = $(this)
        key = configElement.data('component-config-key')
        ensure(config, key) if key.indexOf('.') != -1
        eval("config.#{key} = getConfigElementValue(configElement)")
      config
    setConfiguration: (editor, config) ->
      $('*[data-component-config-key]', editor).each ->
        configElement = $(this)
        value = eval("config.#{configElement.data('component-config-key')}")
        setConfigElementValue(configElement, value) if value?
      editor
  )()

  ContentComponent = (api, spi) ->
    components = {}

    IdGenerator =(->
      componentIds = {}

      next: (type) ->
        componentIds[type] = 1 unless componentIds[type]?
        componentIds[type] = componentIds[type] + 1 while $("[data-component-id='#{type}-#{componentIds[type]}']", spi.composer).length != 0
        "#{type}-#{componentIds[type]}"
    )()

    newComponent = (component, id, type, config) ->
      component.data('component-config', config).attr('data-role', 'component').attr('data-component-type', type).attr('data-component-id', id)

    createComponentEditor = (name, id, config) ->
      editor = components[name].editor("template", config)
      newComponent(ComponentEditor.setConfiguration(editor, config), id, name, config)
    createComponentControl = (name, id, config, value) ->
      newComponent(components[name].control("template", value), id, name, config)

    createComponent = (composer, creator) ->
      $('*[data-role="component"]', composer).each ->
        component = $(this)
        component.replaceWith(creator(component.data('component-type'),
          component.data('component-id'), ComponentEditor.getConfiguration(component), {}))
    destroyComponent = (composer, destroy) ->
      $('*[data-role="component"]', composer).each ->
        component = $(this)
        type = components[component.data('component-type')]
        return $.error("no such component #{component.data('component-type')}") unless type
        type[destroy](component) if type[destroy]

    extensionPoints: ->
      spi.installComponent = (name, component) -> components[name] = component
      spi.insertComponent = (component) -> spi.composer.append(component)

      api.insertComponent = (name, config = {}) ->
        return $.error("no such component #{name}") unless components[name]
        return $.error("components can only be created in edit mode") unless api.mode() == 'edit'
        spi.insertComponent(createComponentEditor(name, IdGenerator.next(name), config))

    extensions: ->
      spi.mode 'edit',
        on: (composer) -> createComponent(composer, createComponentEditor)
        off: (composer) -> destroyComponent(composer, 'destroyEditor')
      spi.mode 'preview',
        on: (composer) -> createComponent(composer, createComponentControl)
        off: (composer) -> destroyComponent(composer, 'destroyControl')

  $.fn.honegger.defaults.plugins.push(ContentComponent)
  $.fn.honegger.defaults.defaultMode = 'edit')(jQuery)