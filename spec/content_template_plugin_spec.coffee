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
        layoutEditor: ->
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
    expect($('div[data-component-type="textbox"]', $(result.template)).length).toBe(1)
    expect(result.config).toEqual({'blank-page-1' : { 'textbox-1' : { 'label' : '' } } })
    expect(result.content).toEqual({'blank-page-1' : { 'textbox-1' : { 'content' : 'content' } }})
