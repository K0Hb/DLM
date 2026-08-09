Rails.application.routes.draw do
  devise_for :users

  resources :users, except: %i[destroy]
  resources :customers
  resources :doctors
  resources :patients
  resources :services

  resources :my_tasks, only: %i[index show] do
    member do
      post :start
      post :complete
      post :attach_photos
      delete :purge_photo
    end
  end

  resource :technician_payment, only: %i[new create]
  resources :technician_payouts, only: :index
  resources :customer_payment_orders, only: :index
  resource :customer_payment, only: %i[new create]
  resources :payment_events, only: :index
  resources :customer_payment_events, only: :index
  get "my_earnings", to: redirect { |_params, req|
    q = req.query_parameters.merge("tab" => "earnings")
    "/my_tasks?#{Rack::Utils.build_query(q)}"
  }

  resources :work_orders do
    member do
      post :advance
      post :rollback
      post :attach_photos
      delete :purge_photo
    end
    resources :work_order_services, only: %i[create update destroy] do
      member do
        post :start
        post :complete
        post :rollback
      end
    end
  end

  resources :deliveries, only: :index do
    member do
      post :mark_sent
    end
  end

  scope path: "reports", controller: :reports, as: :reports do
    get "/", action: :index
    get :work_orders
    get :payroll
    get :unpaid
    get :funnel
    get :customers
    get :services
  end

  get "o/:public_token", to: "public_orders#show", as: :public_order

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
