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
      extraPlugins: [textboxPlugin]

  it 'should create editor based on template', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button data-layout="two-column"></button></div>')
      spi: context.spi
    ).editor()
    expect($(".page-content", editor).length).toBe(1)
    expect($('*[data-layout="two-column"]', editor).length).toBe(1)

  it 'should add component editor', ->
    editor = $.fn.honegger.page(
      template: $('.page-template')[0].outerHTML
      layoutEditor: ->
        $('<div><button data-layout="two-column"></button></div>')
      componentEditor: ->
        $('<div><button data-component="rich-text"></button></div>')
      spi: context.spi
    ).editor()
    expect($('*[data-component="rich-text"]', editor).length).toBe(1)

  it 'should append layout to page', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button data-component="rich-text"></button></div>')
      layouts:
        'one-column' :
          layout: $('.one-column').html()
      spi: context.spi
    ).editor()

    $('.add-layout', editor).click()
    expect($('.section-column', editor).length).toBe(1)
    expect($('.section-column *[data-component="rich-text"]', editor).length).toBe(1)

  it 'should append component to section', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="textbox"></button></div>')
      layouts:
        'one-column' :
          layout: $('.one-column').html()
      spi: context.spi
    ).editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

    expect($('.section-column div[data-component-type="textbox"]', editor).length).toBe(1)

  it 'should switch to control mode', ->
    page = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="textbox"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column').html()
      spi: context.spi
    )
    editor = page.editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

    control = page.control(editor)

    expect($('.component-container', control).length).toBe(1)
    expect($('.add-layout', control).length).toBe(0)
    expect($('.add-component', control).length).toBe(0)
    expect($('textarea[data-component-type="textbox"]', control).length).toBe(1)

  it 'should be able to switch back to editor mode from control mode', ->
    page = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="textbox"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column').html()
      spi: context.spi
    )
    editor = page.editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

    control = page.control(editor)
    editor = page.editor(control)

    expect($('.component-container', editor).length).toBe(1)
    expect($('.add-layout', editor).length).toBe(1)
    expect($('.add-component', editor).length).toBe(1)

  it 'should be able to switch back to editor mode and add components', ->
    page = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="textbox"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column').html()
      spi: context.spi
    )
    editor = page.editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

    control = page.control(editor)
    editor = page.editor(control)

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

  it 'should be able to get template from page', ->
    page = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="textbox"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column').html()
      spi: context.spi
    )
    editor = page.editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()
    placeholder = page.placeholder(editor)

    expect($('[data-component-config-key="title"]', placeholder).length).toBe(0)
    expect($('div[data-component-type="textbox"]', placeholder).length).toBe(1)
