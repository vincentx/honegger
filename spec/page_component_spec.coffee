describe 'page component', ->
  context = {}
  label =
    dataTemplate: {content: 'content'}
    editor: ->
      $("<div><input id='label' type='text' data-component-config-key='label'><input name='content' type='text'></div>")
    destroyEditor: (editor) ->
    control: ->
      $("<textarea></textarea>")
    destroyControl: (contorl) ->
  textboxPlugin = (api, spi) ->
    context.spi = spi
    extensions: ->
      spi.installComponent 'textbox', label

  beforeEach ->
    loadFixtures('page-component.html')

    $("#composer").honegger
      extraPlugins: [textboxPlugin, Page, PageList, Theme]

  xit 'should create editor based on template', ->
    editor = $.fn.honegger.page(
      addColumnButton: ->
        $('<div class="add-column-panel"><button class="add-column" data-column-type="two-column"></button></div>')
      spi: context.spi
    ).editor()
    expect($(".page-content", editor)).toHaveLength(1)
    expect($('*[data-column-type="two-column"]', editor)).toHaveLength(1)

  xit 'should add column to page', ->
    editor = $.fn.honegger.page(
      addColumnButton: ->
        $('<div><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column' :
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    ).editor()
    $('.add-column:first', editor).click()
    expect($('.section-column', editor)).toHaveLength(2)
    expect($('.add-column', editor)).toHaveLength(2)

  xit 'should insert component to page', ->
    editor = $.fn.honegger.page(
      addColumnButton: ->
        $('<div><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column' :
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    ).editor()

    $('.add-column', editor).click()
    $('.add-component', editor).click()

    expect($('.section-column div[data-component-type="textbox"]', editor).length).toBe(1)

  xit 'should switch to control mode', ->
    # need to insert component
    page = $.fn.honegger.page(
      addColumnButton: ->
        $('<div class="add-column-panel"><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    )
    editor = page.editor()

    $('.add-column:first', editor).click()
    control = page.control(editor)

    expect($('.column .component-container', control)).toHaveLength(2)
    expect($('.add-column', control)).toHaveLength(0)

  xit 'should be able to switch back to editor mode from control mode', ->
    page = $.fn.honegger.page(
      addColumnButton: ->
        $('<div class="add-column-panel"><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    )
    editor = page.editor()

    $('.add-column:first', editor).click()

    control = page.control(editor)
    editor = page.editor(control)

    expect($('.component-container', editor)).toHaveLength(2)
    expect($('.add-column', editor)).toHaveLength(2)

  xit 'should be able to switch back to editor mode and add components', ->
    #need insert component
    page = $.fn.honegger.page(
      addColumnButton: ->
        $('<div class="add-column-panel"><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    )
    editor = page.editor()

    $('.add-column:first', editor).click()
    expect($('.section-column', editor)).toHaveLength(2)

    control = page.control(editor)
    editor = page.editor(control)

    $('.add-column:first', editor).click()
    expect($('.section-column', editor)).toHaveLength(3)

  xit 'should be able to get template from page', ->
    # need to insert component
    page = $.fn.honegger.page(
      addColumnButton: ->
        $('<div class="add-column-panel"><button class="add-column" data-column-type="one-column"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column')[0].outerHTML
      spi: context.spi
    )
    editor = page.editor()

    $('.add-column', editor).click()
    placeholder = page.placeholder(editor)
    expect(placeholder.find('.column')).toHaveLength(2)
    expect($('[data-component-config-key="title"]', placeholder).length).toBe(0)
