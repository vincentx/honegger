describe 'components in different mode', ->
  context = {}

  component =
    editor: (template, config)->
      editor = $(template)
      editor.find('.component-header').html('TextArea')
      editor
    dataTemplate:
      content: ''
    control: () ->
      $('<div>\n<textarea class=\"component-control\" data-template-field=\"content\"></textarea>\n<div>\n')

  beforeEach ->
    loadFixtures('component-mode.html')
    this.addMatchers
      toBeInEditMode: ->
        editor = $('table[data-component-type="textarea"]', this.actual)
        control = $('.component-control', this.actual)
        editor.length > 0 && control.length == 0
      toBeInControlMode: ->
        editor = $('table[data-component-type="textarea"]', this.actual)
        control = $('.component-control', this.actual)
        editor.length == 0 && control.length > 0

    context.composer = $('#component-mode-composer')
    context.composer.honegger()
    context.composer.honegger("installComponent", "textarea", component)
    select_column(context.composer, $editable.column)

  it 'should insert component editor', ->
    context.composer.honegger("insertComponent", "textarea", {})
    expect(context.composer).toBeInEditMode()

  it 'should be able to change form editor to control mode', ->
    context.composer.honegger("insertComponent", "textarea", {})
    context.composer.honegger("changeMode", "control")
    expect(context.composer).toBeInControlMode()

  it 'should be able to change form control to editor mode', ->
    context.composer.honegger("insertComponent", "textarea", {})
    context.composer.honegger("changeMode", "control")
    context.composer.honegger("changeMode", "edit")
    expect(context.composer).toBeInEditMode()
