class PagesController < ApplicationController

  before_action :allow_iframe

  def index
  end
  
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
