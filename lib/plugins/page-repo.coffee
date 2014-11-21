window.PageRepo = (api, spi)->

  template = {}
  content = {}

  extensionPoints: ->
    api.insertPage = (name) ->
      if template[name]
        spi.insertComponent(spi.composer, 'page', template: template[name], content[name])
        spi.composer.trigger('honegger.appendNewPage')

    api.addNewPage = (name, page_template, page_content) ->
      template[name] = page_template
      content[name] = page_content

    spi.pageList = -> Object.keys(template)

  extensions: $.noop

  initialize: $.noop