describe 'multiple sections composer', ->
  context = {}

  beforeEach ->
    loadFixtures('multi-sections-composer.html')
    context.composer = $('#composer')

  shouldBehaviorLikeAComposer(context)
