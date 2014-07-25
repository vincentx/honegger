describe 'content component extension point', ->
  context = {}
  textboxPlugin = (key = 'label') ->
    (api, spi) ->
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
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('newComponent', 'textbox', label: 'title')
    expect($('#label', composer).length).toBe(1)

  it 'should set configuration element in editor', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('newComponent', 'textbox', label: 'title')
    expect($('#label', composer).val()).toBe('title')

  it 'should set configuration element for nested structure', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin('label.en')]
    composer.honegger('newComponent', 'textbox', label: { en: 'title'})
    expect($('#label', composer).val()).toBe('title')





