class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper :all

  before_filter :authenticate_user!,
    :move_xml_params,
    :set_locale,
    :set_time_zone,
    :get_announcements

  def set_time_zone
    if current_user and !current_user.time_zone.blank?
      Time.zone = ActiveSupport::TimeZone[current_user.time_zone]
    end
  end

  # Sets the locale according to the first subdomain or redirects to a localized
  # version of the requested URL
  def set_locale
    locale = I18n.default_locale
    
    if I18n.available_locales.map(&:to_s).include?(request.subdomains.first)
      locale = request.subdomains.first
    end

    I18n.locale = locale.to_sym
  end

  # This method is used to work around the fact that there is only
  # one allowed root node in a well formed XML document, we remove
  # the root node so we get to pretend that XML === JSON
  def move_xml_params
    if request.content_type =~ /xml/
      params.merge! params.delete(:api)
    end
  end

  # Redirects users to their account page after sign-in
  def after_sign_in_path_for(resource)
    session[:user_return_to] or account_path
  end

  def get_announcements
    if params[:action] == 'visitor' || (params[:controller] == "accounts" && params[:action] == "show")
      @announcements = Announcement.active.all
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :time_zone) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :password, :ga_otp, :yk_otp) }
    #devise_parameter_sanitizer.for(:account_update) { |u| u.permit! }

  end
end
