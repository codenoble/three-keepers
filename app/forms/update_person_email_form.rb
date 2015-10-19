class UpdatePersonEmailForm < Reform::Form
  include Coercion

  property :address, type: String

  validates :address, presence: true
end
