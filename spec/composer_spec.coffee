describe 'honegger:composer', ->
  beforeEach ->
    jasmine.getFixtures().set '<ul data-role="toolbar">
                  <li><a data-command="bold"/></li></ul>
                  <div id="composer"></div>'
    $("#composer").honegger()

  it 'should store widget instance in data attribute', ->
    expect($("#composer").data('honegger')).toBeDefined()

  it 'should set mark class honegger-composer', ->
    expect($('#composer')[0]).toHaveClass('has-honegger')

  it 'should exec command if selection within current composer', ->
    mockValidSelection()
    spyOn(document, 'execCommand')
    $('#composer').honegger('execCommand', 'bold')
    expect(document.execCommand).toHaveBeenCalledWith('bold')

  it 'should not exec command if selection not in current composer', ->
    spyOn(document, 'execCommand')
    $('#composer').honegger('execCommand', 'bold')
    expect(document.execCommand).not.toHaveBeenCalled()

  mockValidSelection = ->
    $('#composer').append('<span id="selection"></span>')
    spyOn(window, 'getSelection').andReturn(
      getRangeAt: (index) ->
        startContainer: $('#selection')[0]
      rangeCount: 5)









