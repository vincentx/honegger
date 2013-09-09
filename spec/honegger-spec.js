(function() {
  describe('honegger:configuration:default', function() {
    it('multiple sections should be enabled', function() {
      return expect($.fn.honegger.defaults.multipleSections).toBe(true);
    });
    it('ctrl/meta + b to bold text should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['ctrl+b meta+b']).toBe('bold');
    });
    it('ctrl/meta + i to italic text should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['ctrl+i meta+i']).toBe('italic');
    });
    it('ctrl/meta + u to underline text should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['ctrl+u meta+u']).toBe('underline');
    });
    it('ctrl/meta + z to undo changes should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['ctrl+z meta+z']).toBe('undo');
    });
    it('ctrl/meta + y or meta+shift+z to redo changes should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['ctrl+y meta+y meta+shift+z']).toBe('redo');
    });
    it('tab to ident text should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['tab']).toBe('indent');
    });
    return it('shift + tab to outdent text should be enabled', function() {
      return expect($.fn.honegger.defaults.hotkeys['shift+tab']).toBe('outdent');
    });
  });

}).call(this);
