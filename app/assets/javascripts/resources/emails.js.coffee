label_field = $('.search-field')

if label_field.length == 1
  value_field = label_field.next('.hidden-field')

  label_field.autocomplete
    source: label_field.data('lookup-url'),
    select: (e, ui) ->
      e.preventDefault()
      value_field.val ui.item.value

      $(this).val ui.item.label

# A button next to a password field meant to toggle showing the password
# Example: <input type="password">
#          <button class="show-password" type="button">
#            <i class="fa fa.eye"></i>
#          </button>
$('button.show-password').each (i, btn) ->
  btn = $(btn)
  icon = $(btn).find('i')

  btn.on 'click', (e) ->
    pass = $(e.currentTarget).prev('input')
    if pass.attr('type') == 'password'
      icon.removeClass 'fa-eye'
      icon.addClass 'fa-eye-slash'
      pass.attr('type', 'text')
    else
      icon.removeClass 'fa-eye-slash'
      icon.addClass 'fa-eye'
      pass.attr('type', 'password')
