jasmine.getFixtures().fixturesPath = 'spec/fixtures'

select = (selector, element) ->
  $(selector).append($(element))
  window.getSelection().setPosition($("#selection")[0], 1)

read = (fixture) -> jasmine.getFixtures().read(fixture)

$inside = '.inside'
$outside = '.outside'

$editable = {
  paragraph: read('_editable_paragraph.html')
}

