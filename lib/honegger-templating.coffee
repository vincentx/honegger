(($) ->
  ContentTemplating = (api, spi) ->
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

    setConfigElementValue = (configElement, value) ->
      if configElement.attr('type') == 'checkbox' then configElement.prop('checked', value) else configElement.val(value)

    createComponentEditor = (name, id, config) ->
      editor = components[name].editor("template", config)
      $('*[data-component-config-key]', editor).each ->
        configElement = $(this)
        value = eval("config.#{configElement.attr('data-component-config-key')}")
        setConfigElementValue(configElement, value) if value?
      newComponent(editor, id, name, config)
    createComponentControl = (name, id, config, value) ->
      newComponent(components[name].control("template", value), id, name, config)

    extensionPoints: ->
      spi.installComponent = (name, component) -> components[name] = component
      spi.insertComponent = (component) -> spi.composer.append(component)

      api.insertComponent = (name, config = {}) ->
        return $.error("no such component #{name}") unless components[name]
        return $.error("components can only be created in edit mode") unless api.mode() == 'edit'
        spi.insertComponent(createComponentEditor(name, IdGenerator.next(name), config))

    extensions: ->
      spi.mode 'edit',
        on: (composer) ->
          $('*[data-role="component"]', composer).each ->
            component = $(this)
            component.replaceWith(createComponentEditor(component.data('component-type'),
              component.data('component-id'), component.data('component-config')))
        off: (composer) ->
      spi.mode 'preview',
        on: (composer) ->
          $('*[data-role="component"]', composer).each ->
            component = $(this)
            component.replaceWith(createComponentControl(component.data('component-type'),
              component.data('component-id'), component.data('component-config'), {}))
        off: (composer) ->

  $.fn.honegger.defaults.plugins.push(ContentTemplating)
  $.fn.honegger.defaults.defaultMode = 'edit')(jQuery)