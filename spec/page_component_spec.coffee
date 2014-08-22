describe 'page component', ->
  beforeEach ->
    loadFixtures('page-component.html')

  it 'should create editor based on tempalte', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button data-layout="two-column"></button></div>')
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
    ).editor()

    $('.add-layout', editor).click()
    expect($('.section-column', editor).length).toBe(1)
    expect($('.section-column *[data-component="rich-text"]', editor).length).toBe(1)

  it 'should append component to section', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="rich-text"></button></div>')
      layouts:
        'one-column' :
          layout: $('.one-column').html()
      api:
        installComponent: (target, name, config) ->
          target.append($('<div data-component-id="rich-text-1" data-component-type="rich-text"></div>'))
    ).editor()

    $('.add-layout', editor).click()
    $('.add-component', editor).click()

    expect($('.section-column div[data-component-id="rich-text-1"]', editor).length).toBe(1)

  it 'should switch to control mode', ->
    page = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button class="add-layout" data-layout="one-column"></button></div>')
      componentEditor: ->
        $('<div><button class="add-component" data-component="rich-text"></button></div>')
      layouts:
        'one-column':
          layout: $('.one-column').html()
      api:
        installComponent: (target, name, config) ->
          target.append($('<div data-component-id="rich-text-1" data-component-type="rich-text"></div>'))
    )
    editor = page.editor()

    $('.add-layout', editor).click()

    control = page.control({}, editor)

    expect($('.component-container', control).length).toBe(1)
    expect($('.add-layout', control).length).toBe(0)
    expect($('.add-component', control).length).toBe(0)





