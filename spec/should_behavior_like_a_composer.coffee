shouldBehaviorLikeAComposer = (context) ->
  describe 'initialize composer ', ->
    it 'should store widget instance in data attribute', ->
      expect(context.composer.data('honegger')).toBeDefined()

    it 'should set mark class honegger-composer', ->
      expect(context.composer[0]).toHaveClass('honegger-composer')


  describe 'execute command', ->
    beforeEach ->
      spyOn(document, 'execCommand')

    it 'should execute command if selection inside composer', ->
      select($inside, $editable.paragraph)
      context.composer.honegger('execCommand', 'bold')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should execute command if selection outside composer', ->
      select($outside, $editable.paragraph)
      context.composer.honegger('execCommand', 'bold')
      expect(document.execCommand).not.toHaveBeenCalled()

  describe 'response to hotkeys', ->
    beforeEach ->
      spyOn(document, 'execCommand')
      select($inside, $editable.paragraph)

    it 'should be able use to ctrl + b to bold item', ->
      press('ctrl', 'B')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should be able use to meta + b to bold item', ->
      press('meta', 'B')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should be able use to ctrl + i to italic item', ->
      press('ctrl', 'I')
      expect(document.execCommand).toHaveBeenCalledWith('italic')

    it 'should be able use to meta + i to italic item', ->
      press('meta', 'I')
      expect(document.execCommand).toHaveBeenCalledWith('italic')




