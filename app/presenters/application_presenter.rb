class ApplicationPresenter
  attr_reader :model

  def self.presents(model_class)
    @model_class = model_class
  end

  def self.model_class
    @model_class
  end

  def initialize(model)
    @model = model
  end

  def to_param
    model.to_param
  end

  def self.as_sentence(*methods)
    methods.each do |meth|
      define_method "#{meth}?" do
        model.send(meth).present?
      end

      define_method meth do
        model.send(meth).try(:to_sentence)
      end
    end
  end

  def self.as_yes_no(*methods)
    methods.each do |meth|
      define_method meth do
        model.send(meth).present? ? 'Yes' : 'No'
      end
    end
  end

  def self.find(id)
    new(model_class.find(id))
  end

  def self.map(models)
    models.map { |model| self.new(model) }
  end

  def self.model_name
    model_class.model_name
  end

  def method_missing(meth, *args, &block)
    if model.respond_to? meth
      model.send(meth, *args, &block)
    else
      super
    end
  end

  def respond_to?(meth)
    model.respond_to?(meth) || super
  end
end
