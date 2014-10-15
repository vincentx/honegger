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

  extensionPoints: ->
    spi.getColumn = (column_type) ->
      if columns[column_type] then $(columns[column_type].clone()).addClass(column_type) else $('')

    spi.setColumn = (column_type, column_dom) ->
      columns[column_type] = column_dom

  extensions: $.noop
  initialize: $.noop


