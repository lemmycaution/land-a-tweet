class PagesController < ApplicationController

  before_action :allow_iframe

  def show
    if params[:id]
      @user = User.find(params[:id])
    end
    @page = Page.find_by(slug: params[:slug])
    @fallback = File.read("#{Rails.root}/app/views/pages/fallbacks/#{params[:slug]}.html.erb") rescue nil
    redirect_to "/404" and return if @page.nil? and @fallback.nil?
  end
  
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
