PAGE_NUMBER_LIMITATION = 6
window.PageList = (api, spi) ->
  options =
    template: '<li>'+
                '<div class="page-tab">' +
                  '<span class="title"></span>' +
                  '<input type="text" class="form-control edit-title hide" placeholder="page name" maxlength="20">' +
                  '<div class="button-group default-mode">' +
                    '<i class="icon icon-pencil-1 edit-page"></i>' +
                    '<i class="icon remove-page icon-trash"></i>' +
                  '</div>' +
                  '<div class="button-group edit-mode hide">' +
                    '<i class="icon icon-ok save-edit"></i>' +
                    '<i class="icon icon-cancel cancel-edit"></i>' +
                  '</div>' +
                '</div>' +
              '</li>',
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
    page_id = target.attr('data-page-id')
    order_pages.find("li[data-page-id='#{page_id}']").addClass('active-page-tab')
    spi.composer.find('.active-page').removeClass('active-page')
    spi.composer.find("[data-component-id='#{page_id}']").find('.page-content').addClass('active-page')
      .find('.column').removeClass('highlight').end()
      .find('.column:first').addClass('highlight').end()
      .find('.column-container').removeClass('active').end()
      .find('.column-container:first').addClass('active').end()
      .find('.section-block:first').addClass('active').end()
      .find('.section-column').removeClass('active').end()
      .find('.section-column:first').addClass('active')

  build_page_control_by_page_order = ->
    order_pages.find('li').remove()
    contents = spi.composer.find('[data-component-type="page"]').map (index, item)->
      page = $(item)
      $.extend(id: page.attr('data-component-id'), page.data('component-content'))
    contents = _.sortBy contents, (item)-> item.order
    _.each contents, (item)-> append_new_page_control(item.title, item.id)

  assign_page_order = ->
    controls.find('li').each (index, item)->
      page_id = $(item).attr('data-page-id')
      spi.composer.find("[data-component-id='#{page_id}'] > input[name='order']").val(index)

  initEvents = ->
    container.on('click', '.add-page', (e) ->
      api.insertPage('blank') unless spi.composer.find('[data-component-type="page"]').length is PAGE_NUMBER_LIMITATION
    )

    $('.page-order-list').on('click', 'li', (e) -> locate_page($(e.currentTarget)))

    $('.page-list-indicator').on('click', '.open-create-bar', (e) ->
      $('.page-list-container').css('margin-left', '0px').focus()
    )

    time = null
    $('.page-list-container').mouseleave(->
      self = $(this)
      time = setTimeout( ->
        $('.remove-page', self).popover('hide')
        self.css('margin-left', '-220px')
        $('.edit-mode').not('.hide').find('.cancel-edit').click()
      ,
      1000))

    $('.page-list-container').mouseenter(->
      clearTimeout(time))
    container.find('.add-page').tooltip(options.tooltip)
    controls.sortable(
      cursor: 'move'
      opacity: 0.5
      containment: '.page-list'
      stop: ->
        $('.page-list-container .page-order-list li').each (index, item) ->
          item = $(item)
          original_id = item.attr('data-page-id')
          $("[data-component-id='#{original_id}']").data('page-order', index)
          if item.attr('data-page-id', "page-#{index + 1}").hasClass('active-page-tab')
            $($('.page-list-indicator .page-order-list li').removeClass('active-page-tab')[index]).addClass('active-page-tab')

        spi.composer.find('[data-component-type="page"]').each (_, page) ->
          page = $(page)
          index = page.data('page-order')
          page.attr('data-component-id', "page-#{index + 1}")
            .find('input[name="order"]').val(index)
    )


  highlight_page = (current)->
    order_pages.find('.active-page-tab').removeClass('active-page-tab')
    order_pages.find(current).addClass('active-page-tab')
    spi.composer.find('.active-page').removeClass('active-page')
    current_page = controls.find('.active-page-tab').data('page-id')
    spi.composer.find("[data-component-id='#{current_page}']").find('.page-content').addClass('active-page')
      .find('.column').removeClass('highlight').end()
      .find('.column:first').addClass('highlight').find('.column-container').addClass('active')
      .end().find('.section-column:first').addClass('active')

  append_new_page_control = (title, page_id)->
    new_indicator = $(options.indicator_template)
    indicators.append(new_indicator)
    new_indicator.attr('title', title).attr('data-page-id', page_id).tooltip(options.tooltip)

    page_tab = $(options.template)
    controls.append(page_tab)
    delete_button = $('.remove-page', page_tab)
    title_input = $('.edit-title', page_tab)
    default_buttons = $('.default-mode', page_tab)
    edit_buttons = $('.edit-mode', page_tab)
    page_title = ''

    sync_input = ->
      title = title_input.val().trim()
      title = 'blank' if title == ''
      title_input.prev('.title').text(title)
      $('.page-list-indicator').find("[data-page-id='#{page_id}']").attr('data-original-title',title)
      return title

    toggle_buttons = ->
      edit_buttons.toggleClass('hide')
      default_buttons.toggleClass('hide')
      title_input.toggleClass('hide').prev('.title').toggleClass('hide')

    delete_page = ->
      page_tab = $("[data-page-id='#{page_id}']")
      current = if page_tab.next('li').length == 0 then page_tab.prev('li') else page_tab.next('li')
      highlight_page "[data-page-id='#{current.attr("data-page-id")}']"
      page_tab.remove()
      $("[data-component-id='#{page_id}']").remove()

    $('.edit-title', page_tab).on 'keypress', (e)->
      if e.which == 13
        $('.save-edit',page_tab).click()

    $('.edit-page', page_tab).on 'click', ->
      $('.edit-mode').not('.hide').find('.cancel-edit').click()
      page_title = $('.title',page_tab).text().trim()
      toggle_buttons()
      title_input.val(page_title)

    $('.save-edit', page_tab).on 'click', ->
      page_title = sync_input()
      toggle_buttons()
      spi.composer.find("[data-component-id='#{page_id}'] > input[name='title']").val(page_title)

    $('.cancel-edit', page_tab).on 'click', ->
      toggle_buttons()

    content = '<div>
                <span class="content">Are you sure?</span>
                <a class="btn button delete-page" class="btn save">Delete</a>
               </div>'

    delete_button.popover(
      html: true
      container: page_tab
      trigger: 'manual'
      title: ''
      content: -> content
      placement: 'right'
    )

    delete_button.click ->
      $(this).popover('toggle') if $(".page-list .page-order-list").children().length > 1

    $('.showcase-editor.composer').on 'document-click', (e, target) ->
      target_popover = $(target).closest('.popover')
      target_button = $(target).closest('.remove-page')
      if target_popover.length is 0 && ( target_button.length == 0 || target_button[0] != delete_button[0])
        delete_button.popover('hide')

    page_tab.on 'click', '.delete-page', (e) ->
      delete_button.popover('destroy')
      delete_page()
      $('.page-list-container').trigger('mouseleave')

    page_tab.attr('data-page-id', page_id).find('.title').text(title)

  extensionPoints: $.noop

  extensions: ->
    spi.composer.on 'honegger.syncPages', ->
      build_page_control_by_page_order()
      highlight_page('li:first')

    spi.composer.on 'honegger.appendNewPage', ->
      page = spi.composer.find('[data-component-type="page"]:last')
      title = page.find('[name="title"]').val()
      page_id = page.data('component-id')
      append_new_page_control(title, page_id)
      highlight_page('li:last')
      assign_page_order()

  initialize: ->
    initEvents()
