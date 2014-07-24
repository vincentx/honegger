describe 'content component extension point', ->
  context = {}
  textboxPlugin = (key = 'label') ->
    (composer, api, spi, options) ->
      extensions: ->
        spi.installComponent 'textbox',
          editor: ->
            $("<div><input id='label' type='text' data-component-config-key='#{key}'></div>")
          control: ->
            $("<textarea></textarea>")

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'should install component to composer', ->
    component =
      editor: jasmine.createSpy(), control: jasmine.createSpy()
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
      extraPlugins: [textboxPlugin()]
    editor = composer.honegger('newComponent', 'textbox', label: 'title')
    expect($('#label', editor).val()).toBe('title')

  it 'should set configuration element for nested structure', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin('label.en')]
    editor = composer.honegger('newComponent', 'textbox', label: { en: 'title'})
    expect($('#label', editor).val()).toBe('title')





