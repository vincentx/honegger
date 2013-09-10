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
