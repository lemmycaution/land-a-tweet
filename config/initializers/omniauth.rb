Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["API_KEY"], ENV["API_SECRET"], {:image_size => 'bigger'}
end
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}