BitcoinBank::Application.routes.draw do
  resources :invoices, :only => [:index, :new, :create, :show, :destroy]

  resource :user, :only => [:edit, :update] do
    get :ga_otp_configuration

    resources :yubikeys, :only => [:index, :create, :destroy]
    resources :bank_accounts, :only => [:index, :create, :destroy]
    resources :tickets do
      resources :comments, :only => :create
      member do
        post :close
        post :reopen
        post :solve
      end
    end
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  # These routes need some loving :/
  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    get '/balance/:currency',
      :action => 'balance',
      :as => 'balance'

    get :deposit
    get :pecunix_deposit_form
    
    resources :transfers, :only => [:index, :new, :create, :show] 
    
    resources :trades, 
      :only => [:index]
    
    resources :invoices

    resources :trade_orders, :only => [:index, :new, :create, :destroy, :my] do
      post :activate
    end
  end

  get "/s/:name" => "static_pages#show", :as => :static
  
  post '/third_party_callbacks/:action',
    :controller => :third_party_callbacks

  namespace :admin do
    %w{ announcements yubikeys static_pages currencies tickets comments }.each { |r| resources(r.to_sym) {as_routes} }

    resources :pending_transfers do
      as_routes
      
      member do
        post :process_tx
      end
    end
    
    resources :users do
      as_routes
      
      member do
        get :balances
      end
      
      resources :account_operations do
        as_routes
      end
    end
    
    get '/balances', :to => 'home#balances', :as => :balances
  end
  
  get '/qrcode/:data.png' => 'qrcodes#show', :as => :qrcode
  
  get '/order_book' => 'trade_orders#book'
  get '/my_orders' => 'trade_orders#my_orders', :as => :my_orders

  get '/trades' => 'trades#all_trades'

  get '/ticker' => 'trades#ticker'

  get '/economy' => 'home#economy', :as => :economy

  get '/support' => 'home#support', :as => :support
  get '/user/yubikeys/enable', to: 'yubikeys#enable', as: :yubikeys_enable
  get '/user/yubikeys/disable', to: 'yubikeys#disable', as: :yubikeys_disable
  get '/user/gauth', to: 'gauth#index', as: :gauth
  get '/user/gauth/reset', to: 'gauth#reset', as: :gauth_reset
  get '/user/gauth/enable', to: 'gauth#enable', as: :gauth_enable
  get '/user/gauth/disable', to: 'gauth#disable', as: :gauth_disable


  get '/user/change_passsword', to: 'password#form', as: :change_password
  patch '/user/change_passsword', to: 'password#update', as: :change_password_patch
  post '/user/change_passsword', to: 'password#update', as: :change_password_post

  get '/user/notification_settings', to: 'notification_settings#index', as: :notification_settings
  patch '/user/notification_settings', to: 'notification_settings#update', as: :notification_settings_patch

  root :to => 'home#index'
end
