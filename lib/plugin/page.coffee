(($) ->
  PAGE_LIMITATION = 6

  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    removeControls = (page) ->
      $(page).children().each ->
        $(this).remove() unless $(this).hasClass('page-content')
      $('.layout-container', page).children().each ->
        $(this).remove() unless $(this).hasClass("sections")
      $('.component-container', page).children().each ->
        $(this).remove() unless $(this).hasClass("components")
      page

    dataTemplate: {}

    editor: (page) ->
      page = if page then page.clone(true) else $(options.template)

      page.unbind('click').bind('click', '.add-layout', (e)->
        layout = $(e.target).parents('a').attr('data-layout')

        if options.layouts[layout]
          layoutTemplate = $(options.layouts[layout].layout).clone()
          layoutTemplate.insertAfter($('.layout-container.active-page .sections .active').parent());
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
                    '<div class="one-column">' +
                      '<div class="section-block active">' +
                          '<div class="section-column component-container">' +
                            '<div class="components"></div>' +
                          '</div>' +
                      '</div>' +
                      '<div class="layout-panel" title="Add layout">' +
                        '<a class="add-layout" data-layout="one-column"><i class="icon icon-columns"></i></a>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>'

  Page = (api, spi) ->
    options =
      layoutEditor: ->

      componentEditor: ->

      layouts:
        'one-column':
            layout: $('<div class="one-column">' +
                        '<div class="section-block">' +
                          '<div class="section-column component-container">' +
                            '<div class="components"></div>' +
                          '</div>' +
                        '</div>' +
                        '<div class="layout-panel" title="Add layout">' +
                          '<a class="add-layout" data-layout="one-column"><i class="icon icon-columns"></i></a>' +
                        '</div>' +
                      '</div>')

    extensionPoints: ->
      spi.installPage = (name, config) ->
        if ($('article div.page-content').length == PAGE_LIMITATION)
          return false

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
