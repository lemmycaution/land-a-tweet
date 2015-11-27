module PagesHelper
  include ActionView::Template::Handlers

  def render_page page
    body = page ? page.body : @fallback
    ERB.erb_implementation.new(body).result(binding).html_safe
  end

end
