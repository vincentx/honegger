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
    page.find('.column').append(options.addColumnButton())

    page.on('click', '.add-column', (e)->
      column_type = $(this).attr('data-column-type')

      if options.spi.getColumn(column_type)
        columnTemplate = $(options.spi.getColumn(column_type)).clone()
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
      element = $('<div class="column-container">
         <div class="add-column-panel">
          <a class="add-column-button"><i class="icon icon-columns"></i></a>
         </div>
         <div class="column-select-panel" title="Add layout">
          <p>Choose column you want to insert</p>
          <ul>
            <li class="add-column" data-column-type="single">
              <div class="option-block">
               <div class="option-column"></div>
              </div>
            </li>
            <li class="add-column" data-column-type="two-equals">
              <div class="option-block">
                <div class="option-column"></div>
                <div class="option-column"></div>
              </div>
            </li>
            <li class="add-column" data-column-type="one-with-left-sidebar">
              <div class="option-block">
                <div class="option-column section-sidebar"></div>
                <div class="option-column"></div>
              </div>
            </li>
            <li class="add-column" data-column-type="one-with-right-sidebar">
              <div class="option-block">
                <div class="option-column"></div>
                <div class="option-column section-sidebar"></div>
              </div>
            </li>
            <li class="add-column" data-column-type="three-equals">
              <div class="option-block">
                <div class="option-column"></div>
                <div class="option-column"></div>
                <div class="option-column"></div>
              </div>
            </li>
            <li class="add-column" data-column-type="one-with-two-sidebars">
              <div class="option-block">
                <div class="option-column section-sidebar"></div>
                <div class="option-column"></div>
                <div class="option-column section-sidebar"></div>
              </div>
            </li>
          </ul>
        </div>
      </div>')

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

    spi.composer.on('click', '.section-column', (event)->
      $('.active-page').find('.column').removeClass('highlight').find('.section-column.active').removeClass('active').end().
        find('.column-container.active').removeClass('active')
      $(event.currentTarget).addClass('active').parents('.column').addClass('highlight').find('.column-container').addClass('active')
    )
