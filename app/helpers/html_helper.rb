module HtmlHelper
  def truncated_array(array, length: 4, wrapper_tag: :code)
    short_array = array.take(length)
    short_array << '…' if array.length > short_array.length

    safe_join(short_array.map { |el| content_tag(wrapper_tag, el) }, ' ')
  end
end
