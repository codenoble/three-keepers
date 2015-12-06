class DepartmentEmailForm < Reform::Form
  include Coercion

  property :id, type: String
  property :address, type: String
  property :uuids, type: Array
  property :first_name, type: String
  property :last_name, type: String
  property :department, type: String
  property :title, type: String
  property :privacy, type: Boolean

  validates :address, :uuids, :first_name, :last_name, presence: true

  def to_param
    id.to_s
  end
end
