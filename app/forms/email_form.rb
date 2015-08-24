class EmailForm < Reform::Form
  include Coercion

  property :uuid, type: String
  property :address, type: String
  property :primary, type: Boolean

  validates :uuid, :address, presence: true
end
