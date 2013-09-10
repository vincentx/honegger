(function() {
  describe('honegger:composer', function() {
    var mockValidSelection;
    beforeEach(function() {
      jasmine.getFixtures().set('<ul data-role="toolbar">\
                  <li><a data-command="bold"/></li></ul>\
                  <div id="composer"></div>');
      return $("#composer").honegger();
    });
    it('should store widget instance in data attribute', function() {
      return expect($("#composer").data('honegger')).toBeDefined();
    });
    it('should set mark class honegger-composer', function() {
      return expect($('#composer')[0]).toHaveClass('has-honegger');
    });
    it('should exec command if selection within current composer', function() {
      mockValidSelection();
      spyOn(document, 'execCommand');
      $('#composer').honegger('execCommand', 'bold');
      return expect(document.execCommand).toHaveBeenCalledWith('bold');
    });
    it('should not exec command if selection not in current composer', function() {
      spyOn(document, 'execCommand');
      $('#composer').honegger('execCommand', 'bold');
      return expect(document.execCommand).not.toHaveBeenCalled();
    });
    return mockValidSelection = function() {
      $('#composer').append('<span id="selection"></span>');
      return spyOn(window, 'getSelection').andReturn({
        getRangeAt: function(index) {
          return {
            startContainer: $('#selection')[0]
          };
        },
        rangeCount: 5
      });
    };
  });

}).call(this);

(function() {
  describe('honegger:configuration:default', function() {
    it('multiple sections should be enabled', function() {
      return expect($.fn.honegger.defaults.multipleSections).toBe(true);
    });
    it('data-role=toolbar should be used as the selector for toolbar', function() {
      return expect($.fn.honegger.defaults.toolbar).toBe('*[data-role="toolbar"]');
    });
    it('data-command should be used as the toolbar button command', function() {
      return expect($.fn.honegger.defaults.buttons).toBe('*[data-command]');
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
