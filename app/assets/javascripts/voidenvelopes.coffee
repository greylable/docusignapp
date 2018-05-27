$(document).on 'turbolinks:load', ->
  $('#selectall').click ->
    d = $(this).data()
#    console.log(d.checked)
#    if d.checked
##      console.log('hello')
#      $(':checkbox').prop 'checked'
#     access the data object of the button
    $(':checkbox').prop 'checked', !d.checked
#    console.log(!d.checked)
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