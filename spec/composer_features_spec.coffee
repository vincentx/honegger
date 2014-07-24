describe 'pluggable composer features', ->
  context = {}

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'feature should be able to add new mode to composer', ->
    composer = context.composer.honegger
      features:
        test: (honegger) ->
          honegger.mode 'test', (composer) ->

    expect(context.composer.honegger('modes')).toEqual(['test'])
