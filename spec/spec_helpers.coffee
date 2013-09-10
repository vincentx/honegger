jasmine.getFixtures().fixturesPath = 'spec/fixtures'

select = (selector, element) ->
  $(selector).append($(element))
  window.getSelection().setPosition($("#selection")[0], 1)

press = (e)->
  selection = window.getSelection()
  if selection.getRangeAt? && selection.rangeCount
    range = selection.getRangeAt(0)
    $(range.startContainer).parents('[contenteditable]').trigger(e)


read = (fixture) ->
  jasmine.getFixtures().read(fixture)

ctrl = (key) ->
  e = keydown(key)
  e.ctrlKey = true
  e

meta = (key) ->
  e = keydown(key)
  e.metaKey = true
  e

shift = (key) ->
  e = keydown(key)
  e.shiftKey = true
  e

meta_shift = (key) ->
  e = keydown(key)
  e.metaKey = true
  e.shiftKey = true
  e

keydown = (key) ->
  e = $.Event('keydown')
  e.which = if typeof key == 'string' then key.charCodeAt(0) else key
  e

$inside = '.inside'
$outside = '.outside'

$editable = {
  paragraph: read('_editable_paragraph.html')
}

$tab = 9
