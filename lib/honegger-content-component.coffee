(($) ->
  ComponentEditor = (->
    getValue = (element) ->
      if element.attr('type') == 'checkbox' then element.is(':checked') else element.val();

    setValue = (element, value) ->
      if element.attr('type') == 'checkbox' then element.prop('checked', value) else element.val(value)

    ensureExist = (config, key) ->
      struct = config
      for field in key.split('.')
        struct[field] = {} unless struct[field]?
        struct = struct[field]

    setValues = (editor, values, selector) ->
      $("*[#{selector}]", editor).each ->
        element = $(this)
        value = eval("values.#{element.attr(selector)}")
        setValue(element, value) if value?
      editor

    getValues = (editor, values, selector, filter_selector="data-role='component'") ->
      $("[#{selector}]", editor).not($("[#{filter_selector}] [#{selector}]", editor)).each ->
        element = $(this)
        key = element.attr(selector)
        ensureExist(values, key) if key.indexOf('.') != -1
        eval("values.#{key} = getValue(element)")
      values


    getConfiguration: (editor) -> getValues(editor, editor.data('component-config') || {}, 'data-component-config-key')

    getContent: (editor) ->  getValues(editor, editor.data('component-content') || {}, 'name')

    new: (target, component, config, value = component.dataTemplate) ->
      editor = setValues(component.editor(target, config), config, 'data-component-config-key')
      setValues(editor, value, 'name') if value?
      editor
  )()

  ContentComponent = (api, spi) ->
    components = {}

    IdGenerator =(->
      componentIds = {}

      next: (type) ->
        componentIds[type] = 1 unless componentIds[type]?
        componentIds[type] = componentIds[type] + 1 while $("[data-component-id='#{type}-#{componentIds[type]}']",
          spi.composer).length != 0
        "#{type}-#{componentIds[type]}"
    )()

    newComponent = (component, id, type, config) ->
      component.data('component-config', config).attr('data-role', 'component').attr('data-component-type', type)
      .attr('data-component-id', id)

    createComponentEditor = (target, name, id, config, value) ->
      newComponent(ComponentEditor.new(target, components[name], config, value), id, name, config)
    createComponentControl = (target, name, id, config, value) ->
      newComponent(components[name].control(target, value), id, name, config).data('component-content', value)
    createPlaceHolder = (target, name, id, config, value) ->
      placeholder = if components[name].placeholder? then components[name].placeholder(target) else $('<div></div>')
      newComponent(placeholder, id, name, config).data('component-content', value)

    createComponent = (components, creator) ->
      components().each ->
        component = $(this)
        component.replaceWith(creator(component, component.data('component-type'),
          component.data('component-id'), ComponentEditor.getConfiguration(component), ComponentEditor.getContent(component)))
    destroyComponent = (destroy) ->
      spi.components().each ->
        component = $(this)
        type = components[component.data('component-type')]
        return $.error("no such component #{component.data('component-type')}") unless type
        type[destroy](component) if type[destroy]

    extensionPoints: ->
      spi.installComponent = (name, component) -> components[name] = component
      spi.insertComponent = (target, name, config = {}) ->
        return $.error("no such component #{name}") unless components[name]
        return $.error("components can only be created in edit mode") unless api.mode() == 'edit'
        target.append(createComponentEditor(null, name, IdGenerator.next(name), config))

      spi.toEditor = (target) ->
        createComponent(->
          $('*[data-role="component"]', target)
        , createComponentEditor)
      spi.toControl = (target) ->
        createComponent(->
          $('*[data-role="component"]', target)
        , createComponentControl)
      spi.toPlaceholder = (target) ->
        createComponent(->
          $('*[data-role="component"]', target)
        , createPlaceHolder)

      spi.getPlaceholder = (component) ->
        createPlaceHolder(component, component.data('component-type'), component.data('component-id'),
          ComponentEditor.getConfiguration(component), ComponentEditor.getContent(component))
      spi.getComponentConfiguration = (component) ->
        ComponentEditor.getConfiguration(component)
      spi.getComponentContent = (component) ->
        ComponentEditor.getContent(component)

      spi.components = (target = spi.composer)-> $('*[data-role="component"]', target)

      api.insertComponent = (name, config = {}) -> spi.insertComponent(spi.composer, name, config)

    extensions: ->
      spi.mode 'edit',
        on:  -> spi.toEditor(spi.composer)
        off:  -> destroyComponent('destroyEditor')
      spi.mode 'preview',
        on: -> spi.toControl(spi.composer)
        off: -> destroyComponent('destroyControl')

  $.fn.honegger.defaults.plugins.push(ContentComponent)
  $.fn.honegger.defaults.defaultMode = 'edit'
)(jQuery)