(($) ->
  ComposerMode = (composer, api, spi, options) ->
    modes = {}
    current = undefined

    spi.mode = (name, handler) ->
      modes[name] = [] unless modes[name]
      modes[name].push(handler)

    api.modes = ->
      name for name of modes
    api.changeMode = (mode) ->
      $.error("no such mode #{mode}") unless modes[mode]

      ($.each modes[current], ->
        this.off(composer)) if current && modes[current]
      $.each modes[mode], ->
        this.on(composer)
      current = mode

    return -> api.changeMode(options.defaultMode)

  Honegger = (element, options) ->
    composer = $(element)
    api = {}
    spi = {}

    installed = options.extensionPoints.map (install) -> install(composer, api, spi, options)
    feature(spi) for name, feature of options.features
    init() for init in installed

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
    extensionPoints: [ComposerMode]
  })(jQuery);