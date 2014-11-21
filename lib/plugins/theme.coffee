window.Theme = (api, spi)->

  highlight_theme = (selected_theme) ->
    $(".showcase-themes-wrapper div.theme").removeClass('active')
    $(".showcase-themes-wrapper div[data-theme=#{selected_theme}]").addClass('active')

  init_themes_list = (selected_theme) ->
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
    selected_theme = 'rainbow' if selected_theme.length == 0
    highlight_theme(selected_theme)

  initEvents = ->
    $('.themes-wrapper .save').on 'click', ->
      iframe = $('.theme-preview-modal #theme-frame')
      theme_type = iframe[0].src.replace(/.*?\//ig, '')
      spi.composer.trigger('chooseTheme', theme_type)
      $('.themes-wrapper').slideUp duration: 300
      $('.theme-preview-modal').modal('hide')

    $('.themes-wrapper .cancel').on 'click', ->
      $('.themes-wrapper').slideUp duration: 300
      $('.theme-preview-modal').modal('hide')
      spi.composer.trigger('closeThemeModal')

    preview_modal = $('.theme-preview-modal')
    iframe = preview_modal.find('#theme-frame')

    $('*[data-theme]').on 'click', (e)->
      target = $(e.currentTarget)
      theme_type = target.attr('data-theme')
      highlight_theme(theme_type)
      preview_modal.removeClass('showcase-preview').addClass('theme-preview')
      iframe[0].src = 'themes/' + theme_type

    iframe.load (e)->
      spi.composer.trigger('loadTheme', e.target.src.replace(/.*themes\//ig, ''))

    $('.composer .theme-button').on 'click', -> init_themes_list(iframe[0].src.replace(/.*themes\//ig, ''))

  extensionPoints: $.noop,
  extensions: $.noop,
  initialize: initEvents