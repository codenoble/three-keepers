class CollectionPresenter
  def initialize(collection)
    @collection = collection
  end

  def method_missing(method, *args, &block)
    if collection.respond_to? method
      value = collection.send(method, *args, &block)
      if value.is_a? ActiveModel::Model
    else
      super
    end
  end

  protected

  attr_reader :collection
end
