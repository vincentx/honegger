describe 'multiple sections composer', ->
  context = {}

  beforeEach ->
    loadFixtures('multi-sections-composer.html')
    context.composer = $('#composer')
    context.composer.honegger()

  shouldBehaviorLikeAComposer(context)

  it 'should not enable contentable for composer', ->
    expect(context.composer[0]).not.toHaveAttr('contenteditable')

  it 'should enable contentable for all composable items in composer', ->
    expect(context.composer.find('*[data-role="composer"]')).toHaveAttr('contenteditable', 'true')

  it 'should inserted section to composer', ->
    context.composer.honegger('insertSection', '<div data-role="composer" class="inside" id="section"></div>')
    expect($("#section")[0]).toHaveAttr('contenteditable')

  it 'should be able to disable', ->
    context.composer.honegger('disable')
    expect(context.composer.find('*[data-role="composer"]')).not.toHaveAttr('contenteditable', 'true')

  it 'should be able to re-enable disabled composer', ->
    context.composer.honegger('disable').honegger('enable')
    expect(context.composer.find('*[data-role="composer"]')).toHaveAttr('contenteditable', 'true')
