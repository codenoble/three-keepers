class EmailPresenter < ApplicationPresenter
  # Presents an email Hash from the google-syncinator API. Most presenters
  #   present a database object but a hash works fine too.
  presents Hash

  def self.map(models)
    models.map { |model| "#{model['_type']}Presenter".constantize.new(model) }
  end
end
