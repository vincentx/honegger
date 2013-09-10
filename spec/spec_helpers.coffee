jasmine.getFixtures().fixturesPath = 'spec/fixtures'

select = (selector, element) ->
  $(selector).append($(element))
  window.getSelection().setPosition($("#selection")[0], 1)

press = (special, key)->
  selection = window.getSelection()
  if selection.getRangeAt? && selection.rangeCount
    range = selection.getRangeAt(0)
    e = $.Event('keydown')
    e.which = key.charCodeAt(0)
    $.each special.split(' '), (index, specialKey) ->
      eval "e.#{specialKey}Key = true"

    $(range.startContainer).parents('[contenteditable]').trigger(e)


read = (fixture) ->
  jasmine.getFixtures().read(fixture)

$inside = '.inside'
$outside = '.outside'

$editable = {
  paragraph: read('_editable_paragraph.html')
}

