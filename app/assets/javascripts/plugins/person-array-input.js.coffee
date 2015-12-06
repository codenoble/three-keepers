### Description ###
# jQuery plugin to dynamically create multiple fields.
# Typically used to support input for backend array data types.

### Example: ###
# <div class="array-input">
#   <div class="list">
#     <!-- render inputs for existing array elements here -->
#   </div>
#   <input type="text" name="article[tags][]" value=""/>
#   <button type="button">Add</button>
#   <input type="hidden" name="article[tags][]" value=""/>
# </div>
# <script>$('.person-array-input').arrayInput()</script>

(($) ->
  $.fn.personArrayInput = ->
    this.each (i, el) ->
      wrapper = $(el)
      list = wrapper.find '.list'
      new_input = wrapper.find('input[type=text]').last()
      button = wrapper.find('button').last()

      new_input.on 'keypress', (e) ->
        append_field(list, new_input, e) if e.which == 13 # Enter
      button.on 'click', (e) -> append_field(list, wrapper, e)

      wrapper.find('button.delete').on 'click', (e) ->
        row = $(e.currentTarget).closest('div')
        row.find('input[type=hidden]').val('')
        row.slideUp()

  append_field = (list, wrapper, e) ->
    new_inputs = wrapper.find('input').filter (i, el) ->
      $(el).parents('.list').length == 0

    new_inputs.each (i, el) ->
      console.log el
      el = $(el)
      added_input = el.clone()
      added_input.attr 'style', ''

      # We disable text fields so that only the hidden field with the key value we want is submitted
      if added_input.attr('type') == 'text'
        added_input.attr 'disabled', true

      added_input.appendTo list
      el.val ''

    e.preventDefault()
    false

) jQuery
