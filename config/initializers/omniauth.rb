# FIXME: Use ENV

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitcvut_oauth2,
           '49502f65-66a2-4b7a-90a3-93bfc68c22ff',
           'm5rEMmXRWH5Z3kca9On1QJ6TPuNDLovh'
end
