class ApiController < ApplicationController

  rescue_from ActiveRecord::RecordInvalid, with: :render_errors
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_filter :ensure_xhr
  helper_method :authenticate_current_user

  protected

  def authenticate_current_user
    render nothing: true, status: 401 unless (current_user.try(:id) == params[:id])
  end

  def render_errors(exception)
    render json: exception.record.errors.to_json, status: 406
  end

  def render_not_found(exception)
    render nothing: true, status: 404
  end  

  def ensure_xhr
    render nothing: true, status: 401 unless request.xhr?
  end

end