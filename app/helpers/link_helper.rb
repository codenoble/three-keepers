module LinkHelper
  def menu_block(html_options = {}, &block)
    MenuBlock.new(self, html_options).render(&block)
  end
end
