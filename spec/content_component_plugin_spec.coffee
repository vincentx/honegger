describe 'content component extension point', ->
  context = {}
  labelEn =
    editor: ->
      $("<div><input id='label' type='text' data-component-config-key='label.en'></div>")
    control: ->
      $("<textarea></textarea>")
  label =
    dataTemplate: {content: 'content'}
    editor: ->
      $("<div><input id='label' type='text' data-component-config-key='label'><input name='content' type='text'></div>")
    destroyEditor: (editor) ->
    control: ->
      $("<textarea></textarea>")
    destroyControl: (contorl) ->

  textboxPlugin = (component = label) ->
    (api, spi) ->
      extensions: ->
        spi.installComponent 'textbox', component

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'should install component to composer', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')

    component = $('*[data-role="component"]', composer)
    expect(component.length).toBe(1)
    expect(component.data('component-id')).toBe('textbox-1')
    expect(component.data('component-type')).toBe('textbox')
    expect(component.data('component-config')).toEqual(label: 'title')

  it 'should generate id for components', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')
    composer.honegger('insertComponent', 'textbox', label: 'title')
    expect($('*[data-component-id="textbox-1"]', composer).length).toBe(1)
    expect($('*[data-component-id="textbox-2"]', composer).length).toBe(1)

  it 'should set configuration element in editor', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')
    expect($('#label', composer).val()).toBe('title')

  it 'should set configuration element for nested structure', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin(labelEn)]
    composer.honegger('insertComponent', 'textbox', label: { en: 'title'})
    expect($('#label', composer).val()).toBe('title')

  it 'should set content value for editor', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')
    expect($('input[name="content"]', composer).val()).toEqual('content')

  it 'should switch all components to content control in preview mode', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title1')
    composer.honegger('insertComponent', 'textbox', label: 'title2')
    composer.honegger('changeMode', 'preview')
    expect($('textarea[data-component-id="textbox-1"]', composer).length).toBe(1)
    expect($('textarea[data-component-id="textbox-1"]', composer).data('component-config')).toEqual(label: 'title1')

    expect($('textarea[data-component-id="textbox-2"]', composer).length).toBe(1)
    expect($('textarea[data-component-id="textbox-2"]', composer).data('component-config')).toEqual(label: 'title2')

  it 'should switch all components to content editor in edit mode', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title1')
    composer.honegger('insertComponent', 'textbox', label: 'title2')
    composer.honegger('changeMode', 'preview')
    composer.honegger('changeMode', 'edit')

    expect($('div[data-component-id="textbox-1"]', composer).length).toBe(1)
    expect($('div[data-component-id="textbox-1"]', composer).data('component-config')).toEqual(label: 'title1')

    expect($('div[data-component-id="textbox-2"]', composer).length).toBe(1)
    expect($('div[data-component-id="textbox-2"]', composer).data('component-config')).toEqual(label: 'title2')

  it 'should not lose configuration during switching in modes', ->
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')

    $('#label', composer).val('new title')

    composer.honegger('changeMode', 'preview')
    expect($('*[data-component-id="textbox-1"]', composer).data('component-config')).toEqual(label: 'new title')

    composer.honegger('changeMode', 'edit')
    expect($('#label', composer).val()).toEqual('new title')

  it 'should destroy editor when switch to preview mode', ->
    spyOn(label, 'destroyEditor')
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')

    composer.honegger('changeMode', 'preview')

    expect(label.destroyEditor).toHaveBeenCalled()

  it 'should destroy control when switch to edit mode', ->
    spyOn(label, 'destroyControl')
    composer = context.composer.honegger
      extraPlugins: [textboxPlugin()]
    composer.honegger('insertComponent', 'textbox', label: 'title')

    composer.honegger('changeMode', 'preview')
    composer.honegger('changeMode', 'edit')

    expect(label.destroyControl).toHaveBeenCalled()






