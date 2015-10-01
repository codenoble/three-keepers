label_field = $('.search-field')
value_field = $('.hidden-field')

if label_field.length == 1 && value_field.length == 1
  label_field.autocomplete
    source: label_field.data('lookup-url'),
    select: (e, ui) ->
      e.preventDefault()
      value_field.val ui.item.value

      $(this).val ui.item.label
