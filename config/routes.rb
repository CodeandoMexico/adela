require 'sidekiq/web'

Adela::Application.routes.draw do
  localized do
    devise_for :users

    as :user do
      get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
      patch 'users/:id' => 'devise/registrations#update', :as => 'user_registration'
    end

    get "/:slug/catalogo" => "organizations#catalog", :as => "organization_catalog"
    root :to => "home#index"


    resources :organizations, only: [:show, :update] do
      post "publish_catalog", :on => :member
      get "publish_later", :on => :member
      get "profile", :on => :member
      get "search", :on => :collection
    end

    resources :inventories do
      collection do
        get "publish"
        get "ignore_invalid_and_save"
      end
    end
  end
  resources :topics do
    post :sort_order, :on => :collection
    get :publish, :on => :collection
  end
  namespace :api, defaults: { format: 'json'} do
    namespace :v1 do

      get "/catalogs" => "organizations#catalogs"

      resources :organizations do
        collection do
          get "catalogs"
        end
      end
    end
  end

  namespace :admin do
    get '/', to: 'base#index', as: 'root'
    get "/users", to: 'base#users', as: 'users'
    get "/organizations", to: 'base#organizations', as: 'organizations'
    get "/acting/:user_id", to: 'base#acting_as', as: 'acting_as'
    post "/stop_acting", to: 'base#stop_acting_as', as: 'stop_acting'
    post "/create_users", to: 'base#create_users', as: "create_users"
  end

  mount Sidekiq::Web => '/sidekiq'
end
