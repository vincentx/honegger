describe 'single section composer', ->
  context = {}

  beforeEach ->
    loadFixtures('single-section-composer.html')
    context.composer = $('#composer')

  shouldBehaviorLikeAComposer(context)


