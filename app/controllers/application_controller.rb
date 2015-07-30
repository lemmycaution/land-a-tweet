class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :authenticate_current_user

  protected

  def current_user
    @current_user ||= session[:user] ? Donor.find_by(id: session[:user]) : nil
  end

  def authenticate_current_user
    render nothing: true, status: 401 unless (current_user.try(:id) == params[:id])
  end
    
end
