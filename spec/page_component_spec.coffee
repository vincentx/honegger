describe 'page component', ->
  beforeEach ->
    loadFixtures('page-component.html')

  it 'should create editor based on tempalte', ->
    editor = $.fn.honegger.page().editor()
    expect($(".page-content", editor).length).toBe(1)

  it 'should add layout editor', ->
    editor = $.fn.honegger.page(
      layoutEditor: ->
        $('<div><button data-layout="two-column"></button></div>')
    ).editor()
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







