describe 'composer mode extension point', ->
  context = {}

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'should be able to add new mode to composer', ->
    composer = context.composer.honegger
      defaultMode: 'test'
      features:
        test: (honegger) ->
          honegger.mode 'test',
            on: ->
            off: ->

    expect(composer.honegger('modes')).toEqual(['test'])

  it 'should turn default mode on when composer initializing', ->
    handler = on: jasmine.createSpy(), off: jasmine.createSpy()
    context.composer.honegger
      defaultMode: 'test'
      features:
        test: (honegger) ->
          honegger.mode 'test', handler
    expect(handler.on).toHaveBeenCalled()


  it 'should turn the current mode off then turn the new mode on', ->
    modeAHandler = on: jasmine.createSpy(), off: jasmine.createSpy()
    modeBHandler = on: jasmine.createSpy(), off: jasmine.createSpy()
    composer = context.composer.honegger
      defaultMode: 'modeA'
      features:
        modeA: (honegger) ->
          honegger.mode 'modeA', modeAHandler
        modeB: (honegger) ->
          honegger.mode 'modeB', modeBHandler

    composer.honegger('changeMode', 'modeB')
    expect(modeAHandler.off).toHaveBeenCalled()
    expect(modeBHandler.on).toHaveBeenCalled()

