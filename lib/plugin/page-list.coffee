window.PageList = (api, spi) ->
  options =
    template: '<div class="page-tab">' +
                '<span class="title"></span>' +
                '<input type="text" class="hide">' +
                '<div class="button-group default-mode">' +
                  '<i class="glyphicon glyphicon-pencil edit-page"></i>' +
                  '<i class="glyphicon glyphicon-trash remove-page"></i>' +
                '</div>' +
                '<div class="button-group edit-mode hide">' +
                  '<i class="glyphicon glyphicon-ok save-edit"></i>' +
                  '<i class="glyphicon glyphicon-remove cancel-edit"></i>' +
                '</div>' +
              '</div>'

  installPage = (pageList, title)->
    page = $(options.template)
    addButton = pageList.find('.add-page')
    page.insertBefore(addButton).find('.title').html(title)
    page.addClass('active-page') if $('.active-page').length == 0

  initEvents = ->
    $('.page-list-container').on('click', '.add-page', (e)->
      e.stopPropagation()
      spi.installPage('new page', {})
      spi.composer.honegger('insertComponent', 'blank')
    )


  extensionPoints: ->
    spi.initPageList = (pageListContainer) ->
      spi.composer.append(pageListContainer)
      pageListContainer

  extensions: ->
    pageList = spi.initPageList($('.page-list').clone().addClass('page-list-container'))
    spi.composer.on('installPage', (event, name, page)->
      installPage(pageList, name)
    )

  initialize: -> initEvents()