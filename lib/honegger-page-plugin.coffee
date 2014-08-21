(($) ->

  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    initComponentContainer = (target) ->
      $('.component-container', target).each ->
        $(this).append(options.componentEditor(options))
      target

    dataTempalte: {}
    editor: (config, component) ->
      editor = component ? $(options.template)
      $('.layout-container', editor).each ->
        $(this).append(options.layoutEditor(options))

      initComponentContainer(editor)

      $('.add-layout', editor).click ->
        layout = $(this).attr('data-layout')
        if options.layouts[layout]
          layoutTemplate = initComponentContainer($(options.layouts[layout].layout))
          $('.add-component', layoutTemplate).click ->
            component = $(this).attr('data-component')
            options.api.installComponent($('.components', $(this).parents('.component-container')), component)
          $('.layout-container .sections', editor).append(layoutTemplate)

      editor

  $.fn.honegger.page.defaults =
    template: '<div>' +
      '<input type="hidden" data-component-config-key="title" value="">' +
      '<div class="page-content layout-container"><div class="sections"></div></div>' +
    '</div>'
)(jQuery);