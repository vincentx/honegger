describe 'composing mode extension point', ->
  context = {}

  beforeEach ->
    loadFixtures('bare-composer.html')
    context.composer = $('#composer')

  it 'should be able to add new composing mode to composer', ->
    composer = context.composer.honegger
      defaultMode: 'test'
      features:
        test: (honegger) ->
          honegger.mode 'test',
            on: ->
            off: ->

    expect(composer.honegger('modes')).toEqual(['test'])

  it 'should turn default composing mode on when composer initializing', ->
    handler = on: jasmine.createSpy(), off: jasmine.createSpy()
    context.composer.honegger
      defaultMode: 'test'
      features:
        test: (honegger) ->
          honegger.mode 'test', handler
    expect(handler.on).toHaveBeenCalled()


  it 'should turn the current composing mode off then turn the new mode on', ->
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

  it 'should allow multi handlers added to a specified composing mode', ->
    handlerA = on: jasmine.createSpy(), off: jasmine.createSpy()
    handlerB = on: jasmine.createSpy(), off: jasmine.createSpy()
    context.composer.honegger
      defaultMode: 'modeA'
      features:
        pluginA: (honegger) ->
          honegger.mode 'modeA', handlerA
        pluginB: (honegger) ->
          honegger.mode 'modeA', handlerB

    expect(handlerA.on).toHaveBeenCalled()
    expect(handlerB.on).toHaveBeenCalled()

  it 'should get default mode as current composing mode', ->
    composer = context.composer.honegger
      defaultMode: 'test'
      features:
        test: (honegger) ->
          honegger.mode 'test',
            on: ->
            off: ->
    expect(composer.honegger('mode')).toEqual('test')

  it 'should get composing mode after mode changed', ->
    composer = context.composer.honegger
      defaultMode: 'modeA'
      features:
        modeA: (honegger) ->
          honegger.mode 'modeA',
            on: ->
            off: ->
        modeB: (honegger) ->
          honegger.mode 'modeB',
            on: ->
            off: ->
    composer.honegger('changeMode', 'modeB')
    expect(composer.honegger('mode')).toEqual('modeB')
