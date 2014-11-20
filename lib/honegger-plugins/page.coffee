$.fn.honegger.page = (options) ->
  options = $.extend({}, $.fn.honegger.page.defaults, options)

  removeControls = (page) ->
    $(page).children().each ->
      $(this).remove() unless $(this).hasClass("page-content")
    $('.layout-container', page).children().each ->
      $(this).remove() unless $(this).hasClass("sections")
    $('.active', page).each -> $(this).removeClass('active')
    $('.column-container', page).each -> $(this).remove()
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
    options.spi.addColumnButton(page)
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
      element.on('click', '.add-column-panel', ->
        $(this).hide().next('.column-select-panel').show()
      ).on('click', 'li', ->
        $(this).closest('.column-select-panel').hide().prev('div.add-column-panel').show()
      )
      element

  extensionPoints: $.noop
  extensions: $.noop
  initialize: ->
    spi.installComponent('page', $.fn.honegger.page($.extend({spi: spi}, options)))
