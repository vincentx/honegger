(($) ->
  #wait component list plugin
  PAGE_LIMITATION = 6

  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    removeControls = (page) ->
      $(page).children().each ->
        $(this).remove() unless $(this).hasClass("page-content")
      $('.layout-container', page).children().each ->
        $(this).remove() unless $(this).hasClass("sections")
      $('.add-column-panel', page).each -> $(this).remove()
      page

    dataTemplate: {}

    editor: (page) ->
      page = if page then page.clone(true) else $(options.template)
      page.find('.column').append(options.addColumnButton())

      page.unbind('click').bind('click', '.add-column', (e)->
        column_type = $(e.target).attr('data-column-type')

        if options.layouts[column_type]
          columnTemplate = $(options.layouts[column_type].layout).clone()
          columnTemplate.append(options.addColumnButton())
          columnTemplate.insertAfter($(e.target).closest('.column'))
      )
      page

    control: (page) ->
      page = $('<div></div>') unless page
      options.spi.toControl(removeControls(page))
      page

    placeholder: (page) ->
      page = $('<div></div>') unless page
      page = page.clone()
      options.spi.toPlaceholder(removeControls(page))
      page

  $.fn.honegger.page.defaults =
    template: '<div>' +
                '<input type="hidden" data-component-config-key="title" value="">' +
                '<div class="page-content layout-container">' +
                  '<div class="sections">' +
                    '<div class="column one-column">' +
                      '<div class="section-block active">' +
                        '<div class="section-column component-container">' +
                          '<div class="components"></div>' +
                        '</div>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>'

  Page = (api, spi) ->
    options =
      addColumnButton: ->
        $('<div class="add-column-panel" title="Add layout">' +
            '<a class="add-column" data-column-type="one-column"><i class="icon icon-columns"></i></a>' +
          '</div>')
      layouts:
        'one-column':
          layout: $('<div class="column one-column">' +
                      '<div class="section-block">' +
                        '<div class="section-column component-container">' +
                          '<div class="components"></div>' +
                        '</div>' +
                      '</div>' +
                    '</div>')

    extensionPoints: ->
      spi.installPage = (name, config) ->
        return false if $('article div.page-content').length == PAGE_LIMITATION

        config = $.extend({spi: spi}, options, config)
        page = $.fn.honegger.page(config)
        spi.installComponent(name, page)
        spi.composer.trigger('installPage', [name, page])

    initialize: ->
      spi.composer.on('click', '.sections > div', (event)->
        $('.active-page').find('.sections .active').removeClass('active')
        $(event.currentTarget).find('.section-block').addClass('active')
      )

  $.fn.honegger.defaults.plugins.push(Page)
)(jQuery)
