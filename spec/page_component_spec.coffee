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




