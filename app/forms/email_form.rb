class EmailForm < Reform::Form
  property :uuid
  property :address
  property :primary

  validates :uuid, :address, presence: true
end
