class PagesController < ApplicationController

  before_action :find_page, only: :show
  before_action :allow_iframe, only: :show, if: '@page.try(:embeddable?)'
  helper_method :jsapi_referer, :jsapi_origin

  def show
    if params[:id]
      @user = User.find(params[:id])
    end
    @fallback = File.read("#{Rails.root}/app/views/pages/fallbacks/#{params[:slug]}.html.erb") rescue nil
    redirect_to "/404" and return if @page.nil? and @fallback.nil?
    render layout: @page.try(:embeddable?) ? 'embed' : 'application'
  end

  private

  def find_page
    @page = Page.find_by(slug: params[:slug])
  end

  def allow_iframe
    referer = request.referer.match(/((http|https):\/\/[\d|\w|\:]*)/).try(:[],0)
    puts "REFERER: #{referer}"
    # response.headers['X-Content-Security-Policy'] = "frame-options #{referer}"    
    response.headers.except! 'X-Frame-Options'
  end

end
