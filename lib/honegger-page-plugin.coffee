(($) ->
  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    initComponentContainer = (target) ->
      $('.component-container', target).each ->
        editor = options.componentEditor(options)
        $(this).append(editor) if editor?
      target

    dataTempalte: {}
    editor: (template, config, component) ->
      editor = component ? $(options.template)
      return editor if $('.add-layout', editor).length != 0

      $('.layout-container', editor).each ->
        $(this).append(options.layoutEditor(options))

      initComponentContainer(editor)

      $('.add-layout', editor).click ->
        layout = $(this).attr('data-layout')
        if options.layouts[layout]
          layoutTemplate = initComponentContainer($(options.layouts[layout].layout))
          $('.add-component', layoutTemplate).click ->
            component = $(this).attr('data-component')
            options.spi.installComponent($('.components', $(this).parents('.component-container')), component)
          $('.layout-container .sections', editor).append(layoutTemplate)

      editor
    control: (template, config, component) ->
      return $('<div></div>') unless component?

      $('.layout-container', component).children().each ->
        $(this).remove() unless $(this).hasClass("sections")
      $('.component-container', component).children().each ->
        $(this).remove() unless $(this).hasClass("components")
      component

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
)(jQuery);