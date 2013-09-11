shouldBehaviorAsHotkeyDisabled = ->
  describe 'response to hotkeys', ->
    beforeEach ->
      spyOn(document, 'execCommand')
      select($inside, $editable.paragraph)

    it 'should be able use to ctrl + b to bold item', ->
      press ctrl('B')
      expect(document.execCommand).not.toHaveBeenCalledWith('bold')

    it 'should be able use to meta + b to bold item', ->
      press meta('B')
      expect(document.execCommand).not.toHaveBeenCalledWith('bold')

    it 'should be able use to ctrl + i to italic item', ->
      press ctrl('I')
      expect(document.execCommand).not.toHaveBeenCalledWith('italic')

    it 'should be able use to meta + i to italic item', ->
      press meta('I')
      expect(document.execCommand).not.toHaveBeenCalledWith('italic')

    it 'should be able use to ctrl + u to underline item', ->
      press ctrl('U')
      expect(document.execCommand).not.toHaveBeenCalledWith('underline')

    it 'should be able use to meta + u to underline item', ->
      press meta('U')
      expect(document.execCommand).not.toHaveBeenCalledWith('underline')

    it 'should be able use to ctrl + z to undo changes', ->
      press ctrl('Z')
      expect(document.execCommand).not.toHaveBeenCalledWith('undo')

    it 'should be able use to meta + z to undo changes', ->
      press meta('Z')
      expect(document.execCommand).not.toHaveBeenCalledWith('undo')

    it 'should be able use to ctrl + y to redo changes', ->
      press ctrl('Y')
      expect(document.execCommand).not.toHaveBeenCalledWith('redo')

    it 'should be able use to meta + y to redo changes', ->
      press meta('Y')
      expect(document.execCommand).not.toHaveBeenCalledWith('redo')

    it 'should be able use to shift + meta + z to redo changes', ->
      press meta_shift('Z')
      expect(document.execCommand).not.toHaveBeenCalledWith('redo')

    it 'should be able use to tab to indent', ->
      press keydown($tab)
      expect(document.execCommand).not.toHaveBeenCalledWith('indent')

    it 'should be able use to shift + tab to outdent', ->
      press shift($tab)
      expect(document.execCommand).not.toHaveBeenCalledWith('outdent')
