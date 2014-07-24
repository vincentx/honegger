describe 'content component extension point', ->
  context = {}

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'should install component to composer', ->
    component = editor: jasmine.createSpy(), control: jasmine.createSpy()
    composer = context.composer.honegger
      extraPlugins: [
        (composer, api, spi, options) ->
          extensions: ->
            spi.installComponent 'textbox', component
      ]
    composer.honegger('newComponent', 'textbox')
    expect(component.editor).toHaveBeenCalled()

  it 'should set configuration element in editor', ->
    composer = context.composer.honegger
      extraPlugins: [
        (composer, api, spi, options) ->
          extensions: ->
            spi.installComponent 'textbox',
              editor: ->
                $("<div><input id='label' type='text' data-component-config-key='label'></div>")
      ]
    editor = composer.honegger('newComponent', 'textbox', label: 'title')
    expect($('#label', editor).val()).toBe('title')




