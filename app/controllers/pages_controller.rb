class PagesController < ApplicationController

  before_action :find_page, only: :show
  before_action :allow_iframe, only: :show, if: '@page.try(:embeddable?)'

  def show
    if params[:id]
      @user = User.find(params[:id])
    end
    @fallback = File.read("#{Rails.root}/app/views/pages/fallbacks/#{params[:slug]}.html.erb") rescue nil
    redirect_to "/404" and return if @page.nil? and @fallback.nil?
    render layout: @page.try(:embeddable?) ? 'embed' : 'application'
  end
  
  def jsapi
    render layout: false, content_type: "application/javascript"
  end

  private

  def find_page
    @page = Page.find_by(slug: params[:slug])
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
