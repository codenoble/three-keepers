class AccountEmailPresenter < ApplicationPresenter
  include Rails.application.routes.url_helpers

  # Presents an account email Hash from the google-syncinator API. Most
  # presenters present a database object but a hash works fine too.
  presents Hash

  [:id, :address].each do |attrib|
    define_method(attrib) do
      model[attrib.to_s]
    end
  end
  alias :to_s :address

  def path
    case model['_type']
    when 'PersonEmail'
      person_email_path(id)
    when 'DepartmentEmail'
      department_email_path(id)
    end
  end
end
