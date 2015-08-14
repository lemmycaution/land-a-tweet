class Admin::BaseController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_admin_user!
  layout 'admin'

  protected

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || admin_root_path
  end

  def after_sign_out_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || admin_root_path
  end

end
