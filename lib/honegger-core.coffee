(($) ->
  ComposingMode = (api, spi) ->
    modes = {}
    current = undefined

    extensionPoints: ->
      spi.mode = (name, handler) ->
        modes[name] = [] unless modes[name]
        modes[name].push(handler)
      api.mode = -> current
      api.modes = -> name for name of modes
      api.changeMode = (mode) ->
        $.error("no such mode #{mode}") unless modes[mode]

        ($.each modes[current], -> this.off()) if current && modes[current]
        $.each modes[mode], -> this.on()
        current = mode
    initialize: ->
      api.changeMode(spi.options.defaultMode)

  Honegger = (element, options) ->
    composer = $(element)
    api = {}
    spi = composer : composer, options: options

    plugins = options.plugins.concat(options.extraPlugins).map (plugin) -> plugin(api, spi)

    plugin.extensionPoints() for plugin in plugins when plugin.extensionPoints
    plugin.extensions() for plugin in plugins when plugin.extensions
    plugin.initialize() for plugin in plugins when plugin.initialize

    return api

  $.fn.honegger = (options)->
    isMethodCall = typeof(options) == 'string'
    parameters = $.makeArray(arguments).slice(1)
    returnValue = this

    methodCall = ->
      instance = $.data(this, 'honegger')
      return $.error("no such method #{options}") unless instance[options]
      value = instance[options].apply(instance, parameters)
      if value != instance && value
        returnValue = value
        return false

    initComponent = ->
      instance = $.data(this, 'honegger')
      $.data(this, 'honegger', new Honegger(this, $.extend({}, $.fn.honegger.defaults, options))) unless instance

    this.each if isMethodCall then methodCall else initComponent
    returnValue
  $.fn.honegger.defaults = {
    plugins: [ComposingMode]
    extraPlugins: []
  })(jQuery);