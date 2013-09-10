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
      $('#composer').honegger('execCommand', 'bold')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should execute command if selection outside composer', ->
      select($outside, $editable.paragraph)
      $('#composer').honegger('execCommand', 'bold')
      expect(document.execCommand).not.toHaveBeenCalled()




