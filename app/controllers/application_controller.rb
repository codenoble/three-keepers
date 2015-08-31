class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate!

  helper_method :current_user
  def current_user
    @current_user ||= CurrentUserPresenter.new(session)
  end

  # mongoid_userstamp is included in trogdir_models. In trogdir-api it gets used to track which
  # Syncinator created and updated things. In this app that doesn't happen. It could be tied to
  # Person but people don't write much and I feel it would just complicate things. So we're just
  # setting the user to nil. This is mostly an issue in tests for factories anyway.
  helper_method :null_person
  def null_person
    nil
  end

  protected

  # This is meant to be overridden by concerns that search other things
  def search_route() :people end
  helper_method :search_route

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
