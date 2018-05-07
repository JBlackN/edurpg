# FIXME: Use ENV

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitcvut_oauth2,
           ENV['CLIENT_ID'],
           ENV['CLIENT_SECRET']
end
