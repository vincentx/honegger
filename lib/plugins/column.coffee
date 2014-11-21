window.Column = (api, spi)->
  base =
      '<div class="column">' +
        '<div class="section-block"></div>' +
      '</div>'

  column =
      '<div class="section-column component-container">' +
        '<div class="components"></div>' +
      '</div>'

  columns =
    single:
      $('.section-block', $(base))
      .append(column)
      .parent()

    'two-equals':
      $('.section-block', $(base))
      .append(column)
      .append(column)
      .parent()

    'one-with-left-sidebar':
      $('.section-block', $(base))
      .append($(column).addClass('section-sidebar'))
      .append(column)
      .parent()

    'one-with-right-sidebar':
      $('.section-block', $(base))
      .append(column)
      .append($(column).addClass('section-sidebar'))
      .parent()

    'three-equals':
      $('.section-block', $(base))
      .append(column)
      .append(column)
      .append(column)
      .parent()

    'one-with-two-sidebars':
      $('.section-block', $(base))
      .append($(column).addClass('section-sidebar'))
      .append(column)
      .append($(column).addClass('section-sidebar'))
      .parent()

  column_panel =
        '<div class="column-container">
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
        </div>'

  extensionPoints: ->
    spi.getColumn = (column_type) ->
      if columns[column_type] then $(columns[column_type].clone()).addClass(column_type) else $('')

    spi.setColumn = (column_type, column_dom) ->
      columns[column_type] = column_dom

    spi.addColumnButton = (page)->
      page.find('.column').append($(column_panel))

  extensions: $.noop

  initialize: ->
    spi.composer.on('click', '.section-column', (event)->
      $('.active-page').find('.column').find('.section-column.active').removeClass('active').end().
      find('.column-container.active').removeClass('active')

      add_column_panel_container = $(event.currentTarget).addClass('active').parents('.column').find('.column-container')
      add_column_panel_container.addClass('active')
      add_column_panel = add_column_panel_container.find('.add-column-panel')

      left = $(event.currentTarget).offset().left
      add_column_panel.offset(left: left)
    )

    spi.composer.on('click', '.add-column-panel', ->
      $(this).css('visibility': 'hidden').next('.column-select-panel').show()
    ).on('click', 'li', ->
      $(this).closest('.column-select-panel').hide().prev('div.add-column-panel').css('visibility': 'visible')
    )

    spi.composer.on('click', '.add-column', (e)->
      column_type = $(this).attr('data-column-type')

      if spi.getColumn(column_type)
        columnTemplate = $(spi.getColumn(column_type)).clone()
        columnTemplate.append $(column_panel)
        columnTemplate.insertAfter($(e.currentTarget).closest('.column'))
    )

    spi.composer.closest('.composer').on 'document-click', (e, target)->
      if $(target).closest('.add-column-panel').length is 0 and $(target).closest('.column-select-panel').length is 0
        $('.column-select-panel').hide()
        $('.add-column-panel').css('visibility': 'visible')