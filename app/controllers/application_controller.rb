class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate!

  helper_method :current_user
  def current_user
    @current_user ||= CurrentUserPresenter.new(session)
  end

  protected

  def authenticate!
    if current_user.authenticated?
      render_error_page(403) unless current_user.authorized?
    else
      render_error_page(401)
    end
  end

  def render_error_page(status)
    render file: "#{Rails.root}/public/#{status}", formats: [:html], status: status, layout: false
  end

  def user_not_authorized
    render_error_page(403)
  end
end
