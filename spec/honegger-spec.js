(function() {
  describe('honegger', function() {
    describe('composer', function() {
      var $editableParagraph, $inside, $outside, select;
      beforeEach(function() {
        jasmine.getFixtures().set('<ul data-role="toolbar">\
              <li><a data-command="bold"/></li></ul>\
              <div class="outside">\
              <div id="composer" class="inside"></div>\
              </div>');
        return $("#composer").honegger();
      });
      it('should store widget instance in data attribute', function() {
        return expect($("#composer").data('honegger')).toBeDefined();
      });
      it('should set mark class honegger-composer', function() {
        return expect($('#composer')[0]).toHaveClass('has-honegger');
      });
      describe('set contenteditable', function() {});
      describe('command execution', function() {
        beforeEach(function() {
          return spyOn(document, 'execCommand');
        });
        it('should exec command if selection within current composer', function() {
          select($editableParagraph, $inside);
          $('#composer').honegger('execCommand', 'bold');
          return expect(document.execCommand).toHaveBeenCalledWith('bold');
        });
        return it('should not exec command if selection not in current composer', function() {
          select($editableParagraph, $outside);
          $('#composer').honegger('execCommand', 'bold');
          return expect(document.execCommand).not.toHaveBeenCalled();
        });
      });
      select = function(element, selector) {
        $('.' + selector).append($(element));
        return window.getSelection().setPosition($("#selection")[0], 1);
      };
      $inside = 'inside';
      $outside = 'outside';
      return $editableParagraph = '<p id="selection">paragraph</p>';
    });
    return describe('default configuration', function() {
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
  });

}).call(this);
