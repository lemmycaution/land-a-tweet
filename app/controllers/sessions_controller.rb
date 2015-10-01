class SessionsController < ApplicationController

  def create
    cookies[:user] = Donor.find_or_create_by_oauth(request.env['omniauth.auth']).id
    # render inline: "<script>window.close()</script>"
    redirect_to root_url(close: true)
  end

  def destroy
    cookies[:user] = nil
    redirect_to (request.referer || root_url), notice: "Signed out!"
  end
  
  def failure
    redirect_to root_url, alert: "Authentication failed, please try again."
  end
  
  def check
    render nothing: true, status: current_user ? 200 : 403
  end
  
  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
