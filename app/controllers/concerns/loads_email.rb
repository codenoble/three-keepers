module LoadsEmail
  extend ActiveSupport::Concern

  PARENT_ROUTES = [:person_email, :department_email, :alias_email]

  included do
    before_action :load_email
  end

  protected

  def load_email
    parent_params = PARENT_ROUTES.map { |r| "#{r}_id" }
    parent_param = params.slice(*parent_params).keys.first
    type = parent_param.gsub(/\_id\Z/, '')

    response = GoogleSyncinator::APIClient::Emails.new.show(id: params[parent_param]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = "#{type}_presenter".classify.constantize.new(raw_email)
    end
  end
end
