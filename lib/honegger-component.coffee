(($) ->
  Components = (spi) ->
    spi.mode 'edit',
      on: (composer) ->
      off: (composer) ->
    spi.mode 'preview',
      on: (composer) ->
      off: (composer) ->

)(jQuery)