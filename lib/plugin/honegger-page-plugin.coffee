(($) ->
  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    initComponentContainer = (target) ->
      $('.component-container', target).each ->
        editor = options.componentEditor(options)
        $(this).append(editor) if editor?
      target
    removeControls = (page) ->
      $(page).children().each ->
        $(this).remove() unless $(this).hasClass("page-content")
      $('.layout-container', page).children().each ->
        $(this).remove() unless $(this).hasClass("sections")
      $('.component-container', page).children().each ->
        $(this).remove() unless $(this).hasClass("components")
      page


    dataTemplate: {}
    editor: (page) ->
      page = $(options.template) unless page
      return page if $('.add-layout', page).length != 0

      $('.layout-container', page).each ->
        $(this).append(options.layoutEditor(options))

      initComponentContainer(page)

      $('.add-layout', page).click ->
        layout = $(this).attr('data-layout')
        if options.layouts[layout]
          layoutTemplate = initComponentContainer($(options.layouts[layout].layout))
          $('.add-component', layoutTemplate).click ->
            component = $(this).attr('data-component')
            options.spi.insertComponent($('.components', $(this).parents('.component-container')), component)
          $('.layout-container .sections', page).append(layoutTemplate)

      options.spi.toEditor(page)
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
      '<div class="page-content layout-container"><div class="sections"></div></div>' +
    '</div>'

  PageComponent = (api, spi) ->
    extensionPoints: ->
      spi.installPage = (name, config) ->
        config = $.extend({}, {spi: spi}, config)
        page = $.fn.honegger.page(config)
        spi.installComponent(name, page)
        spi.composer.trigger('installPage', [name, page])

  $.fn.honegger.defaults.plugins.push(PageComponent)
)(jQuery)