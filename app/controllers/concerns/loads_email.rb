module LoadsEmail
  extend ActiveSupport::Concern

  included do
    before_action :load_email
  end

  protected

  def load_email
    response = GoogleSyncinator::APIClient::Emails.new.show(id: params[:email_id]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = EmailPresenter.new(raw_email)
    end
  end
end
