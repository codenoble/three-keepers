class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate!

  helper_method :current_user
  def current_user
    @current_user ||= CurrentUser.new(session)
  end

  protected

  def authenticate!
    render_error_page(401) unless current_user.authorized?
  end

  def render_error_page(status)
    render file: "#{Rails.root}/public/#{status}", formats: [:html], status: status, layout: false
  end

  def user_not_authorized
    render_error_page(403)
  end
end
