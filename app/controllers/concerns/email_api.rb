module EmailAPI
  extend ActiveSupport::Concern

  protected

  def handle_response(response, options = {})
    email_id_param = options[:email_id_param] || 'email_id'

    if response.success?
      redirect_to email_path(response.parse[email_id_param])
    else
      flash.now[:alert] = "Error from API: #{error_from_api(response)}"
      render :new
    end
  end

  def error_from_api(response)
    response.parse.has_key?('error') ? response.parse['error'] : response.body
  end
end
