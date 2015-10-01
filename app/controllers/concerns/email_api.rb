module EmailAPI
  extend ActiveSupport::Concern

  protected

  def handle_response(response, options = {})
    email_id_param = options[:email_id_param] || 'email_id'
    route = options[:route] || :person_email

    if response.success?
      redirect_to send("#{route}_path", response.parse[email_id_param])
    else
      flash.now[:alert] = "Error from API: #{error_from_api(response)}"
      render :new
    end
  end

  def error_from_api(response)
    response.parse.has_key?('error') ? response.parse['error'] : response.body
  end

  def prep_for_kaminari(api_response)
    collection = api_response.parse

    collection.define_singleton_method(:current_page) do
      api_response.headers['x-page'].to_i
    end

    collection.define_singleton_method(:total_pages) do
      api_response.headers['x-total-pages'].to_i
    end

    collection.define_singleton_method(:limit_value) do
      api_response.headers['x-per-page'].to_i
    end

    collection
  end
end
