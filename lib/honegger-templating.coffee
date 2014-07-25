(($) ->
  ContentTemplating = (api, spi) ->
    components = {}

    setComponent = (component, type, config) ->
      component.data('component-config', config).attr('data-role', 'component').attr('data-component-type', type)


    setConfigElementValue = (configElement, value) ->
      if configElement.attr('type') == 'checkbox' then configElement.prop('checked', value) else configElement.val(value)

    createComponentEditor = (name, config) ->
      editor = components[name].editor("template", config)
      $('*[data-component-config-key]', editor).each ->
        configElement = $(this)
        value = eval("config.#{configElement.attr('data-component-config-key')}")
        setConfigElementValue(configElement, value) if value?
      setComponent(editor, name, config)

    extensionPoints: ->
      spi.installComponent = (name, component) -> components[name] = component
      spi.insertComponent = (component) -> spi.composer.append(component)

      api.insertComponent = (name, config = {}) ->
        return $.error("no such component #{name}") unless components[name]
        return $.error("components can only be created in edit mode") unless api.mode() == 'edit'
        spi.insertComponent(createComponentEditor(name, config))

    extensions: ->
      spi.mode 'edit',
        on: (composer) ->
        off: (composer) ->
      spi.mode 'preview',
        on: (composer) ->
        off: (composer) ->

  $.fn.honegger.defaults.plugins.push(ContentTemplating)
  $.fn.honegger.defaults.defaultMode = 'edit')(jQuery)