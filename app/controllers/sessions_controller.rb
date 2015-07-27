class SessionsController < ApplicationController

  def create
    session[:user] = Donor.find_or_create_by_oauth(request.env['omniauth.auth']).id
    redirect_to root_path, notice: "Signed in!"
  end

  def destroy
    session[:user] = nil
    redirect_to root_path, notice: "Signed out!"
  end
  
  def failure
    redirect_to root_url, alert: "Authentication failed, please try again."
  end
  
  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
