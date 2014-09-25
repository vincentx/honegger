window.Theme = (api, spi) ->
  initEvents = ->
    $('*[data-theme]').on('click', (e)->
      target = $(e.currentTarget)
      frameId = target.attr('data-target')
      $(frameId + '-frame')[0].contentWindow.postMessage('preview', 'http://' + location.host)
      return
    )


  extensionPoints: ->

  extensions: ->

  initialize: -> initEvents()
