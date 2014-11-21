window.ComponentList = (api, spi)->
  list = $('.composer .components-container .components-list')
  initEvents = ->
    list.on('click', '.add-component', ->
      type = $(this).attr('data-component-type')
      return unless type
      active_column = $('.active-page .sections .section-column.active .components', spi.composer)
      spi.insertComponent(active_column, type)
    )

  extensionPoints: $.noop
  extensions: $.noop
  initialize: ->
    spi.installComponent(type, component) for type, component of Components
    initEvents()