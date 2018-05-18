$(document).on 'turbolinks:load', ->
  $('#selectall').click ->
    d = $(this).data()
    # access the data object of the button
    $(':checkbox').prop 'checked', !d.checked
    #    console.log($('#myCheckbox'))
    # set all checkboxes 'checked' property using '.prop()'
    d.checked = !d.checked
    # set the new 'checked' opposite value to the button's data object
    return

  $(':checkbox').click ->
    if @checked
      return
    else
      $(':checkbox').each ->
        $('#selectall').prop('checked', false)
        return
    return

  $('.datepicker').pickadate()
    selectMonths: true
    selectYears: 15
    today: 'Today'
    clear: 'Clear'
    close: 'Ok'
    closeOnSelect: false