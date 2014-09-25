describe 'content template', ->
  context = {}
  label =
    dataTemplate: {content: 'content'}
    editor: ->
      $("<div><input id='label' type='text' data-component-config-key='label'><input name='content' type='text'></div>")
    destroyEditor: (editor) ->
      control: ->
        $("<textarea></textarea>")
      destroyControl: (contorl) ->
  TestPlugin = (api, spi) ->
    extensions: ->
      spi.installPage('blank-page', {
        addColumnButton: ->
          $('<div><button class="add-layout" data-layout="one-column"></button></div>')
        componentEditor: ->
          $('<div><button class="add-component" data-component="textbox"></button></div>')
        layouts:
          'one-column':
            layout: $('.one-column').html()
      })
      spi.installComponent 'textbox', label


  beforeEach ->
    loadFixtures('page-component.html')
    context.composer = $('#composer').honegger
      extraPlugins: [TestPlugin]

  it 'should be able get template, configuration and content', ->
    context.composer.honegger('insertComponent', 'blank-page')

    $('.add-layout', $('div[data-component-id="blank-page-1"]', context.composer)).click()
    $('.add-component', $('div[data-component-id="blank-page-1"]', context.composer)).click()
    result = context.composer.honegger('getContentTemplate')
    expect($('div[data-component-type="textbox"]', $(result.template))).toHaveLength(1)
    expect(result.config).toEqual({'blank-page-1': { title: '', type: 'blank-page'}, 'textbox-1': { label: '', type: 'textbox' } })
    expect(result.content).toEqual({'blank-page-1': {type: 'blank-page'}, 'textbox-1': { content: 'content', type: 'textbox'} })

  it 'should be able load template, configuration and content', ->
    template = '<div data-role="component" data-component-type="blank-page" data-component-id="blank-page-1">'+
                   '<div class="page-content layout-container">'+
                     '<div class="sections">'+
                       '<div class="section-block">'+
                         '<div class="section-column component-container">'+
                           '<div class="components">'+
                             '<div data-role="component" data-component-type="textbox" data-component-id="textbox-1"></div>
                           </div>'+
                         '</div>'+
                       '</div>'+
                     '</div>'+
                   '</div>'+
                 '</div>'
    config =
      'blank-page-1': { title: '', type: 'blank-page'}, 'textbox-1': { label: '', type: 'textbox' }
    content =
      'blank-page-1': {type: 'blank-page'}, 'textbox-1': { content: 'content', type: 'textbox'}
    context.composer.honegger('loadContentTemplate', template, config, content, 'edit')

    page_component = $('[data-component-id="blank-page-1"]', context.composer)
    expect(page_component).toHaveLength(1)
    expect(page_component.data('component-config')).toEqual({title: '', type: 'blank-page'})

    text_component = $('[data-component-id="textbox-1"]', context.composer)
    expect(text_component).toHaveLength(1)
    expect(text_component.data('component-config')).toEqual({label: '', type: 'textbox'})
    expect(text_component.find('input[name="content"]')).toHaveValue('content')
