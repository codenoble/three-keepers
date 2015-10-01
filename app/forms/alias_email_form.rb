class AliasEmailForm < Reform::Form
  include Coercion

  property :account_email_id, type: String
  property :address, type: String

  validates :account_email_id, :address, presence: true
end
