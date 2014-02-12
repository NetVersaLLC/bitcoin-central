BitcoinBank::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.i18n.fallbacks = true

  # Print deprecation notices to the Rails logger
  # config.active_support.deprecation = :log
  
  # Uncomment this to test e-mails in development mode
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.default_url_options = {
    :host => "www.tradebitcoin.com",
    :protocol => 'https'
  }
  
  config.middleware.use ::ExceptionNotifier,
    :email_prefix => "[BC Exception] ",	 	
    :sender_address => %w{no-reply@tradebitcoin.com},
    :exception_recipients => %w{support@tradebitcoin.com}
  
  # Used to broadcast invoices public URLs
  config.base_url = "www.tradebitcoin.com"
  
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.serve_static_assets = false
  config.force_ssl = true

end
