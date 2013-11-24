BitcoinBank::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.force_ssl = false

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = {
    :host => "test.tradebitcoin.com"
  }

  #config.middleware.use ::ExceptionNotifier,
  #  :email_prefix => "[TradeBitcoin Exception] ",
  #  :sender_address => %w{no-reply@test.tradebitcoin.com},
  #  :exception_recipients => %w{support@test.tradebitcoin.com}

  # Used to broadcast invoices public URLs
  config.base_url = "https://test.tradebitcoin.com/"

  config.assets.compress = true
  config.assets.compile = true
  config.assets.digest = true
  config.serve_static_assets = false
  config.cache_store = :mem_cache_store
  config.eager_load = true

end
