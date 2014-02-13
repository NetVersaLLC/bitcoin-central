BitcoinBank::Application.routes.draw do

  resources :invoices, :only => [:index, :new, :create, :show, :destroy]

  resource :user, :only => [:edit, :update] do
    get :ga_otp_configuration
    put :update_password
    get :edit_password

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

  devise_for :users, :controllers => { :registrations => "registrations", :passwords => 'passwords' }

  # These routes need some loving :/
  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    match '/balance/:currency',
      :action => 'balance',
      :as => 'balance',
      :only => :get
      
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

  match "/s/:name" => "static_pages#show", :as => :static
  
  match '/third_party_callbacks/:action',
    :controller => :third_party_callbacks

  namespace :admin do
    %w{ announcements yubikeys static_pages currencies tickets comments }.each { |r| resources(r.to_sym) {as_routes} }

    resources :pending_transfers do
      as_routes
      
      member do
        post :process_tx
        post :cancel_tx
      end
    end
    
    match '/send_cancel_message/:user_id' => "pending_transfers#send_cancel_message", :method => :post, :as => :send_cancel_message

    resources :users do
      as_routes
      
      member do
        get :balances
      end
      
      resources :account_operations do
        as_routes
      end
    end
    
    match '/balances', :to => 'home#balances', :as => :balances
  end
  
  match '/qrcode/:data.png' => 'qrcodes#show', :as => :qrcode
  
  match '/order_book' => 'trade_orders#book'
  match '/my_orders' => 'trade_orders#my_orders', :as => :my_orders

  match '/trades' => 'trades#all_trades'

  match '/ticker' => 'trades#ticker'

  match '/economy' => 'home#economy', :as => :economy

  match '/support' => 'home#support', :as => :support
  get '/user/yubikeys/enable', to: 'yubikeys#enable', as: 'yubikeys_enable'
  get '/user/yubikeys/disable', to: 'yubikeys#disable', as: 'yubikeys_disable'
  get '/user/gauth', to: 'gauth#index', as: 'gauth'
  get '/user/gauth/reset', to: 'gauth#reset', as: 'gauth_reset'
  get '/user/gauth/enable', to: 'gauth#enable', as: 'gauth_enable'
  get '/user/gauth/disable', to: 'gauth#disable', as: 'gauth_disable'


  get '/user/change_passsword', to: 'password#form', as: 'change_password'
  put '/user/change_passsword', to: 'password#update', as: 'change_password'
  post '/user/change_passsword', to: 'password#update', as: 'change_password'

  get '/user/notification_settings', to: 'notification_settings#index', as: 'notification_settings'
  put '/user/notification_settings', to: 'notification_settings#update', as: 'notification_settings'

  root :to => 'home#index'
end
