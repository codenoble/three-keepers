module IconHelper
  def fa_check(bool, *args)
    fa_icon((bool ? 'check-square-o' : 'square-o'), *args)
  end
end
