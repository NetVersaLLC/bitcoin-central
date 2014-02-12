# Be sure to restart your server when you modify this file.

BitcoinBank::Application.config.session_store :active_record_store, 
  :key => "bc-session",
  :domain => :all

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Portal::Application.config.session_store :active_record_store
