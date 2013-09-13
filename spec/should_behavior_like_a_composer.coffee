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


  describe 'highlight toolbar button', ->
    beforeEach ->
      select($inside, $editable.paragraph)
      spyOn(document, 'queryCommandState').andReturn(true)

    it 'should highlight toolbar button', ->
      press keyup('A')
      expect($('a[data-command="bold"]')[0]).toHaveClass('honegger-button-active')

  xdescribe 'insert component', ->
    beforeEach ->
      @enhancer =
        enhance: ->
      spyOn(@enhancer, 'enhance')

    it 'should append component inside composer', ->
      select($inside, $editable.paragraph)
      context.composer.honegger('insertComponent', $components.text)
      expect($('.text-component', context.composer).length).not.toBe(0)

    it 'should run enhancer after component inserted', ->
      select($inside, $editable.paragraph)
      context.composer.honegger('insertComponent', $components.text, @enhancer.enhance)
      expect(@enhancer.enhance).toHaveBeenCalled()

    it 'should not append component outside composer', ->
      select($outside, $editable.paragraph)
      context.composer.honegger('insertComponent', $components.text)
      expect($('.text-component', context.composer).length).toBe(0)

    describe 'editing', ->
      beforeEach ->
        select($inside, $editable.paragraph)
        context.composer.honegger('insertComponent', $components.text)

      it 'should not exec command if selection within component', ->
        spyOn(document, 'execCommand')
        select($inside_component, $editable.paragraph)
        context.composer.honegger('execCommand', 'bold')
        expect(document.execCommand).not.toHaveBeenCalledWith('bold')

      shouldBehaviorAsHotkeyDisabled($inside_component)

  describe 'response to hotkeys', ->
    beforeEach ->
      spyOn(document, 'execCommand')
      select($inside, $editable.paragraph)

    it 'should be able use to ctrl + b to bold item', ->
      press ctrl('B')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should be able use to meta + b to bold item', ->
      press meta('B')
      expect(document.execCommand).toHaveBeenCalledWith('bold')

    it 'should be able use to ctrl + i to italic item', ->
      press ctrl('I')
      expect(document.execCommand).toHaveBeenCalledWith('italic')

    it 'should be able use to meta + i to italic item', ->
      press meta('I')
      expect(document.execCommand).toHaveBeenCalledWith('italic')

    it 'should be able use to ctrl + u to underline item', ->
      press ctrl('U')
      expect(document.execCommand).toHaveBeenCalledWith('underline')

    it 'should be able use to meta + u to underline item', ->
      press meta('U')
      expect(document.execCommand).toHaveBeenCalledWith('underline')

    it 'should be able use to ctrl + z to undo changes', ->
      press ctrl('Z')
      expect(document.execCommand).toHaveBeenCalledWith('undo')

    it 'should be able use to meta + z to undo changes', ->
      press meta('Z')
      expect(document.execCommand).toHaveBeenCalledWith('undo')

    it 'should be able use to ctrl + y to redo changes', ->
      press ctrl('Y')
      expect(document.execCommand).toHaveBeenCalledWith('redo')

    it 'should be able use to meta + y to redo changes', ->
      press meta('Y')
      expect(document.execCommand).toHaveBeenCalledWith('redo')

    it 'should be able use to shift + meta + z to redo changes', ->
      press meta_shift('Z')
      expect(document.execCommand).toHaveBeenCalledWith('redo')

    it 'should be able use to tab to indent', ->
      press keydown($tab)
      expect(document.execCommand).toHaveBeenCalledWith('indent')

    it 'should be able use to shift + tab to outdent', ->
      press shift($tab)
      expect(document.execCommand).toHaveBeenCalledWith('outdent')
