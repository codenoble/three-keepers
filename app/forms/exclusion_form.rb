class ExclusionForm < Reform::Form
  include Coercion

  property :email_id, type: String
  property :creator_uuid, type: String
  property :starts_at, type: DateTime
  property :ends_at, type: DateTime
  property :reason, type: String

  validates :email_id, :creator_uuid, :starts_at, presence: true
end
