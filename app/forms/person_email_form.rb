class PersonEmailForm < Reform::Form
  include Coercion

  property :uuid, type: String
  property :address, type: String

  validates :uuid, :address, presence: true
end
