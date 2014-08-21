(($) ->

  $.fn.honegger.page = (options) ->
    options = $.extend({}, $.fn.honegger.page.defaults, options)

    initComponentContainer = (target) ->
      console.log(options)
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
          $('.layout-container .sections', editor).append(initComponentContainer($(options.layouts[layout].layout)))

      editor

  $.fn.honegger.page.defaults =
    template: '<div>' +
      '<input type="hidden" data-component-config-key="title" value="">' +
      '<div class="page-content layout-container"><div class="sections"></div></div>' +
    '</div>'
)(jQuery);