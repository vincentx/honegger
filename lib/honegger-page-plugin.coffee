(($) ->

  $.fn.honegger.page = (options) ->
    options = $.extend($.fn.honegger.page.defaults, options)

    dataTempalte: {}
    editor: (config, component) ->
      editor = component ? $(options.template)
      $('.layout-container', editor).each ->
        $(this).append(options.layoutEditor(options))
      $('.component-container', editor).each ->
        $(this).append(options.componentEditor(options))
      editor

  $.fn.honegger.page.defaults =
    template: '<div>' +
      '<input type="hidden" data-component-config-key="title" value="">' +
      '<div class="page-content layout-container"><div class="sections"></div></div>' +
    '</div>'
    layoutEditor: (options) ->
)(jQuery);