describe 'single section composer', ->
  context = {}

  beforeEach ->
    loadFixtures('single-section-composer.html')
    context.composer = $('#composer')
    context.composer.honegger(multipleSections: false)

  shouldBehaviorLikeAComposer(context)

  it 'should enable contentable for composer', ->
    expect(context.composer[0]).toHaveAttr('contenteditable', 'true')

  it 'should ignore all composable items in composer', ->
    expect(context.composer.find('*[data-role="composer"]')).not.toHaveAttr('contenteditable')

  it 'should not have insert section method', ->
    context.composer.honegger('insertSection', '<div id="section"></div>')
    expect($("#section").length).toBe(0)

  describe 'disabled composer', ->
    beforeEach ->
      context.composer.honegger('disable')

    it 'should be able to disable', ->
      expect(context.composer[0]).not.toHaveAttr('contenteditable', 'true')

    it 'should be able to re-enable disabled composer', ->
      context.composer.honegger('enable')
      expect(context.composer[0]).toHaveAttr('contenteditable', 'true')

    shouldBehaviorAsHotkeyDisabled()


