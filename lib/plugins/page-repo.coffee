window.PageRepo = (api, spi)->

  template =
    blank: [
      single: [
        ['livetext-resource-title-1-0-0', 'livetext-resource-text-1-0-0'],
      ],
#      'two-equals': [
#        []
#        ['livetext-resource-title-1-0-0', 'livetext-resource-text-1-0-0']
#      ]
    ]
  content =
    blank:
      title: 'blank'

  extensionPoints: ->
    api.insertPage = (name) ->
      if template[name]
        spi.insertComponent(spi.composer, 'page', template: template[name], content[name])
        spi.composer.trigger('honegger.appendNewPage')

    spi.pageList = -> Object.keys(template)

  extensions: $.noop

  initialize: $.noop