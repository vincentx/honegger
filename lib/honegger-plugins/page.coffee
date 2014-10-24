$.fn.honegger.page = (options) ->
  options = $.extend({}, $.fn.honegger.page.defaults, options)

  removeControls = (page) ->
    $(page).children().each ->
      $(this).remove() unless $(this).hasClass("page-content")
    $('.layout-container', page).children().each ->
      $(this).remove() unless $(this).hasClass("sections")
    $('.add-column-panel', page).each -> $(this).remove()
    $('.section-block', page).each -> $(this).removeClass('active')
    page

  construct_column = (column_type, elements)->
    column = options.spi.getColumn(column_type)
    children = column.find('.section-block').children()
    $.each elements, (index, components) ->
      options.spi.insertComponent $(children[index]).find('.components'), name for name in components
      return
    column

  construct_page = (config)->
    template = $(options.template)
    $.each config.template, (_, column_config) ->
      $.each column_config, (column_type, elements)->
        template.find('.sections').append(construct_column(column_type, elements))
    template

  dataTemplate:
    title: 'New Page'
    order: ''

  editor: (page, config, content) ->
    page = if page then page.clone(true).prepend(options.content_template) else construct_page(config)
    page.find('.column').append(options.addColumnButton())

    page.unbind('click').bind('click', '.add-column', (e)->
      column_type = $(e.target).closest('.add-column').attr('data-column-type')

      if options.layouts[column_type]
        columnTemplate = $(options.layouts[column_type].layout).clone()
        columnTemplate.append(options.addColumnButton())
        columnTemplate.insertAfter($(e.target).closest('.column'))
    )
    page

  control: (page) ->
    page = $('<div></div>') unless page
    page

  placeholder: (page) ->
    page = $('<div></div>') unless page
    page = page.clone()
    options.spi.toPlaceholder(removeControls(page))
    page

$.fn.honegger.page.defaults =
  template: '<div>' +
              '<input type="hidden" name="title" value="">' +
              '<input type="hidden" name="order" value="">' +
              '<div class="page-content layout-container">' +
                '<div class="sections"></div>' +
              '</div>' +
            '</div>'
  content_template:
    '<input type="hidden" name="title" value="">' +
    '<input type="hidden" name="order" value="">'

window.Page = (api, spi) ->
  options =
    addColumnButton: ->
      $('<div class="add-column-panel" title="Add layout">' +
          '<a class="add-column" data-column-type="one-column"><i class="icon icon-columns"></i></a>' +
        '</div>')
    layouts:
      'one-column':
        layout: $('<div class="column one-column">' +
                    '<div class="section-block">' +
                      '<div class="section-column component-container">' +
                        '<div class="components"></div>' +
                      '</div>' +
                    '</div>' +
                  '</div>')

  extensionPoints: $.noop

  extensions: $.noop

  initialize: ->
    spi.installComponent('page', $.fn.honegger.page($.extend({spi: spi}, options)))

    spi.composer.on('click', '.sections > div', (event)->
      $('.active-page').find('.sections .active').removeClass('active')
      $(event.currentTarget).find('.section-block').addClass('active')
    )
