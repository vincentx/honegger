(($) ->
  ContentTemplate = (api, spi) ->
    extensionPoints: ->
      api.getContentTemplate = ->
        composer = spi.composer.clone()
        config = {}
        content = {}
        spi.components(composer).each ->
          component = $(this)
          return if component.parents('*[data-role="component"]').length != 0
          component.replaceWith(spi.getPlaceholder($(this))[0].outerHTML)
          config[component.data('component-id')] = spi.getComponentConfiguration(component)
          content[component.data('component-id')] = spi.getComponentContent(component)

        template: composer[0].outerHTML
        config: config
        content: content

  $.fn.honegger.defaults.plugins.push(ContentTemplate)
)(jQuery);