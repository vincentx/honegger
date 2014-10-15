PAGE_NUMBER_LIMITATION = 6
window.PageList = (api, spi) ->
  options =
    template: '<li>'+
                '<div class="page-tab">' +
                  '<span class="title"></span>' +
                  '<input type="text" class="hide">' +
                  '<div class="button-group default-mode">' +
                    '<i class="icon edit-page"></i>' +
                    '<i class="icon remove-page"></i>' +
                  '</div>' +
                  '<div class="button-group edit-mode hide">' +
                    '<i class="icon save-edit"></i>' +
                    '<i class="icon cancel-edit"></i>' +
                  '</div>' +
                '</div>
              </li>',
    indicator_template: '<li data-toggle="tooltip"><i></i></li>',
    tooltip:
      placement: 'right auto',
      delay: 100,
      container: 'body'

  container = $('.composer .create-page-container')
  indicators = container.find('.page-list-indicator .page-order-list')
  controls = container.find('.page-list .page-order-list')
  order_pages = container.find('.page-order-list')

  locate_page = (target) ->
    order_pages.find('li.active-page-tab').removeClass('active-page-tab')
    page_id = target.data('page-id')
    order_pages.find("li[data-page-id='#{page_id}']").addClass('active-page-tab')
    spi.composer.find('.active-page').removeClass('active-page')
    spi.composer.find("[data-component-id='#{page_id}']").find('.page-content').addClass('active-page').find('.section-block:first').addClass('active')

  build_page_control_by_page_order = ->
    order_pages.find('li').remove()
    contents = spi.composer.find('[data-component-type="page"]').map (index, item)->
      page = $(item)
      $.extend(id: page.data('component-id'), page.data('component-content'))
    contents = _.sortBy contents, (item)-> item.order
    _.each contents, (item)-> append_new_page_control(item.title, item.id)


  assign_page_order = ->
    controls.find('li').each (index, item)->
      page_id = $(item).data('page-id')
      spi.composer.find("[data-component-id='#{page_id}'] > input[name='order']").val(index)

  initEvents = ->
    container.on('click', '.add-page', (e) ->
      e.stopPropagation()
      api.insertPage('blank') unless spi.composer.find('[data-component-type="page"]').length is PAGE_NUMBER_LIMITATION
    )

    $('.page-order-list').on('click', 'li', (e) -> locate_page($(e.currentTarget)))

    $('.page-list-indicator').on('click', '.open-create-bar', (e) ->
      e.stopPropagation()
      $('.page-list-container').css('margin-left', '0px').focus()
    )

    $('.page-list-container').mouseleave(-> $(this).css('margin-left', '-165px'))
    container.find('.add-page').tooltip(options.tooltip)

  highlight_page = (current)->
    order_pages.find('.active-page-tab').removeClass('active-page-tab')
    order_pages.find("li:#{current}").addClass('active-page-tab')
    spi.composer.find('.active-page').removeClass('active-page')
    current_page = controls.find('.active-page-tab').data('page-id')
    spi.composer.find("[data-component-id='#{current_page}']").find('.page-content').addClass('active-page').find('.section-block:first').addClass('active')

  append_new_page_control = (title, page_id)->
    new_indicator = $(options.indicator_template)
    indicators.append(new_indicator)
    new_indicator.attr('title', title).attr('data-page-id', page_id).tooltip(options.tooltip)

    page_tab = $(options.template)
    controls.append(page_tab)
    page_tab.attr('data-page-id', page_id).find('.title').text(title)

  extensionPoints: $.noop

  extensions: ->
    spi.composer.on 'honegger.syncPages', ->
      build_page_control_by_page_order()
      highlight_page('first')

    spi.composer.on 'honegger.appendNewPage', ->
      page = spi.composer.find('[data-component-type="page"]:last')
      title = page.find('[name="title"]').val()
      page_id = page.data('component-id')
      append_new_page_control(title, page_id)
      highlight_page('last')
      assign_page_order()

  initialize: ->
    initEvents()
