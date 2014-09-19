(($) ->
  ContentTemplate = (api, spi) ->
    extensionPoints: ->
      api.getContentTemplate = ->
        composer = spi.composer.clone()
        config = {}
        content = {}

        spi.components(composer).each ->
          component = $(this)
          config[component.data('component-id')] = $.extend({}, spi.getComponentConfiguration(component),
            type: component.data('component-type'))
          content[component.data('component-id')] = $.extend({}, spi.getComponentContent(component),
            type: component.data('component-type'))

        spi.components(composer).each ->
          component = $(this)
          return if component.parents('*[data-role="component"]').length != 0
          component.replaceWith(spi.getPlaceholder($(this))[0].outerHTML)

        template: composer[0].outerHTML
        config: config
        content: content

  $.fn.honegger.defaults.plugins.push(ContentTemplate)
)(jQuery)