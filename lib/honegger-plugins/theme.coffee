window.Theme = (api, spi)->
  set_data = ->
    composer = spi.composer
    data = []

    #todo get pages info
    _.each($('[data-role="component"]'), (item)->
      type = $(item).data('component-type')
      temp = {}
      temp[type] = {};
      data.push(temp)
    )
    composer.data('component_data', data)

  init_themes_list = ->
    $('.showcase-themes-wrapper').slideDown
      duration: 300
      complete: ->
        $('.themes-wrapper .slider').slick(
          dots: true
          infinite: false
          speed: 300
          slidesToShow: 6
          slidesToScroll: 6
          responsive: [
            {
              breakpoint: 1490,
              settings:
                slidesToShow: 5
                slidesToScroll: 5
                infinite: true
                dots: true
            },
            {
              breakpoint: 1190,
              settings:
                slidesToShow: 4
                slidesToScroll: 4
                infinite: true
                dots: true
            },
            {
              breakpoint: 960
              settings:
                slidesToShow: 3
                slidesToScroll: 3
                infinite: true
                dots: true
            }
          ])

  initEvents = ->
    $('.themes-wrapper .cancel').on 'click', ->
      $('.themes-wrapper').slideUp({duration: 300})
      $('.theme-preview-modal').modal('hide')

    $('*[data-theme]').on 'click', (e)->
      target = $(e.currentTarget)
      theme_type = target.attr('data-theme')
      iframe = $('.theme-preview-modal #theme-frame')
      iframe[0].src = 'themes/' + theme_type
      iframe.load ->
        spi.composer.trigger('loadTheme', theme_type)

    $('.composer .theme-button').on 'click', ->
      init_themes_list()
      set_data()

  extensionPoints: $.noop,
  extensions: $.noop,
  initialize: initEvents