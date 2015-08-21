label_field = $('#email_uuid_search')
value_field = $('#email_uuid')

label_field.autocomplete
  source: label_field.data('lookup-url'),
  select: (e, ui) ->
    e.preventDefault()
    value_field.val ui.item.value

    $(this).val ui.item.label
