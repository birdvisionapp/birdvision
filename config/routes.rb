Birdvision::Application.routes.draw do

  devise_for :users

  as :user do
    get 'user/edit' => 'devise/registrations#edit', :as => :user_root
    put 'user/:id' => 'devise/registrations#update', :as => 'user_registration'
  end

  devise_scope :user do
    get "/", :to => "devise/sessions#new"
  end

  devise_for :admin_users, :skip => [:registrations]
  as :admin_user do
    get 'admin_user/edit' => 'devise/registrations#edit', :as => :admin_user_root
    put 'admin_user/:id' => 'devise/registrations#update', :as => 'admin_user_registration'
  end

  devise_scope :admin_user do
    get "/admin", :to => "devise/sessions#new"
  end


  root :to => 'devise/sessions#new'


  #static_pages
  get 'privacy_policy' => "static_pages#privacy_policy", :as => :privacy_policy
  get 'faq' => "static_pages#faq", :as => :faq
  get 'terms_and_conditions' => "static_pages#terms_and_conditions", :as => :terms_and_conditions
  get 'contact_us' => "static_pages#contact_us", :as => :contact_us
  post 'contact_request' => "static_pages#contact_request", :as => :contact_request

  #404 page
  get 'render_404' => 'application#render_404', :as => :render_404

  #schemes
  get 'schemes' => 'schemes#index'
  get 'schemes/:id' => 'schemes#show'
  get 'participant_speedometer' => 'schemes#participant_speedometer'
  get 'participant_leaderboard' => 'schemes#participant_leaderboard'
  post 'authenticate' => 'auth#authenticate'

  #status
  get 'status' => 'status#index'

  scope 'schemes/:scheme_slug' do
    get 'catalogs' => 'catalogs#index', :as => :catalogs
    get 'catalogs/:id' => 'catalogs#show', :as => :catalog
    get 'client_items/:slug' => 'client_items#show', :as => :client_item
    get 'search' => 'search#search_catalog', :as => :search_catalog

    namespace :single_redemption do
      constraints ClientTypeConstraint.new(true) do
        post 'redemption' => 'redemption#redeem'
      end
    end

    constraints ClientTypeConstraint.new(false) do
      #Cart
      post 'carts/add' => 'carts#add_item', :as => :add_to_cart
      get 'carts/add' => 'carts#add_item', :as => :add_to_cart
      delete 'carts/:id' => 'carts#remove_item', :as => :remove_from_cart
      get 'carts' => 'carts#index', :as => :carts
      put 'carts/update_item_quantity' => 'carts#update_item_quantity', :as => :update_quantity
    end

    scope 'orders' do
      get 'new' => 'orders#new', :as => :new_order
      post 'preview' => 'orders#create_preview', :as => :create_preview
      get 'preview' => 'orders#preview', :as => :order_preview
      post '' => 'orders#create', :as => :orders
      get ':id' => 'orders#show', :as => :order
      post 'send_otp' => 'orders#send_otp', :as => :send_otp
    end
  end

  get 'orders' => 'orders#index', :as => :order_index

  get 'scheme_transactions' => 'scheme_transactions#index', :as => :points_summary

  namespace :admin do
    get "dashboard" => "admin_dashboard#show", :as => :dashboard
    get "uploads" => "async_jobs#index", :as => :uploads_index
    delete "uploads/:id" => "async_jobs#destroy", :as => :delete_upload
    namespace :sales do
      get "dashboard" => "reseller_dashboard#index", :as => :reseller_dashboard_index
      get "client/:client_id/participants" => "reseller_dashboard#participants", :as => :client_participants
      get "client/:client_id/orders" => "reseller_dashboard#orders", :as => :client_orders
    end

    root :to => 'users#home'
    resources :order_items do
      put :change_status
      get :edit_tracking_info
      put :update_tracking_info
      put :approve_order
    end
    resources :categories

    get "client_item/:id/edit" => 'client_item#edit', :as => :client_item_edit
    put "client_item/:id" => 'client_item#update', :as => :client_item_update
    put "client_catalog/:id/:client_item_id" => 'client_catalog#remove_item', :as => :remove_from_client_catalog

    resources :suppliers

    namespace :user_management do
      get 'dashboard' => "dashboard#home", :as => :dashboard

      resources :super_admins do
        member do
          put :transfer_rights
        end
      end

      resources :client_managers, :regional_managers

      resources :msps do
        collection do
          get :list_options
        end
        resources :super_admins do
          member do
            put :transfer_rights
          end
        end
      end

      resources :representatives do
        collection do
          delete :unlink_user
        end
      end
     
      resource :client_admin do
        get "import_csv" => "client_admin#import_csv", :as => :import_csv
        post "upload_csv" => "client_admin#upload_csv", :as => :upload_csv
        get "csv_template" => "client_admin#csv_template", :as => :csv_template
      end
      resources :resellers do
        get "add_client" => "client_resellers#new", :as => :add_client_for_reseller
        post "add_client" => "client_resellers#create", :as => :associate_client_to_reseller
        get "edit_client/:id" => "client_resellers#edit", :as => :edit_client_for_reseller
        put "edit_client/:id" => "client_resellers#update", :as => :update_client_for_reseller
        put "unassign_client/:id" => "client_resellers#unassign", :as => :unassign_client_for_reseller
      end
      get "representative/:id/edit" => 'representatives#edit', :as => :representative_edit
      put "representative/:id" => 'representatives#update', :as => :representative_update
      get "representative/:id" => 'representatives#show', :as => :representative_show
    end

    resources :master_catalog do
      collection do
        post :add_to_client_catalog
        post :toggle_status
        get :import_csv
        post :upload_csv
      end
    end
    resources :clients do
      get :download_report
      collection do
        get :list_user_roles, :list_telecom_regions
      end
    end
    resources :schemes do
      get :download_report
      get :csv_template

      collection do
        get :list_for_client
      end      
    end

    resources :scheme_catalog

    resources :users do
      collection do
        get :al_csv_template
        get :import_csv
        post :upload_csv
        post :send_activation_email_to
      end
    end
    resources :draft_items do
      collection do
        get :import_csv
        post :upload_csv
      end
      get :lookup
      post :link
      post :publish
    end
    resources :client_catalog do
      get :add_client_price
      put :save_client_price
    end
    resources :level_club_catalog
    resources :scheme_transactions, :only => [:index]
    resources :client_point_reports, :only => [:index]
    namespace :sms_based do
      get 'dashboard' => "dashboard#home", :as => :dashboard
      resources :reward_items, :except => [:destroy] do
        collection do
          get :list_for_scheme
        end
      end
      resources :unique_item_codes, :only => [:index, :new, :create, :show] do
        collection do
          get :report, :track, :load_multi_tier, :multi_tier_conf, :coupons_preview, :download_linkable
          post :track, :print_preview, :download
        end        
      end
      resources :reward_item_points, :except => [:destroy] do
        member do
          put :preview_conf
          put :store_links
        end
        collection do
          get :list_for_scheme, :link_codes
        end
      end
      resources :users, :only => [:index] do
        collection do
          get :login
          post :login
        end
      end
    end
    namespace :regional do
      get 'dashboard' => "dashboard#home", :as => :dashboard
    end

    resources :download_reports, :only => [:index, :destroy] do
      get :download
    end
    resources :client_invoices, :except => [:edit, :update] do
      resources :client_payments, :only => [:new, :create, :show, :edit, :update]
    end
    resources :language_templates
    resources :telecom_circles, :except => [:show]
    put "level_club_catalog/:id/:client_item_id" => 'level_club_catalog#remove_item', :as => :remove_from_level_club_catalog
    put "scheme_catalog/:id/:client_item_id" => 'scheme_catalog#remove_item', :as => :remove_from_scheme_catalog

    resources :widgets
    resources :to_transactions do
       put :to_change_status
       get :to_edit_tracking_info
       put :to_update_tracking_info
    end
    resources :reward_product_catagories do
      collection do
        get :list_for_product_categories
      end
    end
    
    resources :client_managers_widgets, :only => [:index, :create, :destroy] do
      collection do
        get :product_penetration
        get :redemption
        get :top_users
        get :loyalty_index
        get :community_size
        get :community_heft
        get :stockout_risklevel
        get :top_redemptions
        get :traction
        get :reward_item_level
        get "sku_level/:id" => "client_managers_widgets#sku_level", :as=> :sku_level
        get :category_reward_items
        get :overall_product_penetration
        get :penetration
      end
    end
    
    resources :thresholds
    
    resources :targeted_offers do
      collection do
        get :add_offers
      end
    end
    
    resources :targeted_offer_managers , :path => "to_configuration", :controller => "targeted_offer_managers" do
      collection do
        get "targeted_offer_list" => "targeted_offer_managers#to_configured_clients_listing" , :as => :targeted_offer_list
        get :to_config
        get :select_client
        get "offer_manager" => "targeted_offer_managers#offer_manager" ,:as => :offer_manager
        get :template_table
        get :product
        get "campaingn_manager" => "targeted_offer_managers#campaingn_manager" ,:as => :campaingn_manager
        get "communication_manager" => "targeted_offer_managers#communication_manager" ,:as => :communication_manager
        get :to_redemption
        post :store_offer
        post :store_campaingn
        post :store_communication
        get "offer_manager_edit" => "targeted_offer_managers#offer_manager_edit" ,:as => :offer_manager_edit
        get "campaingn_manager_edit" => "targeted_offer_managers#campaingn_manager_edit" ,:as => :campaingn_manager_edit
        get "communication_manager_edit" => "targeted_offer_managers#communication_manager_edit" ,:as => :communication_manager_edit
        post :create_and_store_offer
        get :render_required_templates
        get :gift
      end
    end
    
    resources :templates
    
    resources :al_transactions, :except => [:show] do
      collection do
        get :al_reward_product_points_template
        get :al_reward_product_points_import
        get :al_channel_linkage
        get :channel_linkage_template
        post :al_reward_product_points_upload
        post :parse
        post :parse_channel_linkage
        get :failed_transaction
        get :successful_transaction
        get :upload_linkage
      end
      member do
        delete :delete_al_linkage
        get :edit_al_linkage
        put :update_al_linkage
      end
    end   
  end
  
  resources :user_registrations
    
  namespace :api do
    resources :participants, :except => [:index, :new, :create, :show, :edit, :update, :destroy] do
      collection do
        post :registration, :update_info, :de_activate, :update_points, :forgot_password, :reset_password, :login
        get :rewards
      end
    end    
  end

  get "approve_al_user_details" => "schemes#approve_al_user_details" ,:as => :approve_al_user_details
  post "send_al_user_details" => "schemes#send_al_user_details" ,:as => :send_al_user_details
  get "al_point_report" => "schemes#al_point_report" ,:as => :al_point_report
  mount JasmineRails::Engine => "/specs" if Rails.env.development? || Rails.env.test? #todo - kd - check if this is okay?
  match '/404', :to => 'errors#not_found'
  match '/500', :to => 'errors#server_error'

  # Authentication provider
  match '/auth/bvc/authorize' => 'auth#authorize', :as => :oauth_authorize
  match '/auth/bvc/access_token' => 'auth#access_token', :as => :oauth_access_token
  match '/auth/bvc/user' => 'auth#user', :as => :oauth_user
  match '/auth/bvc/check_token' => 'auth#check_token', :as => :oauth_check_token
  match '/sms_based/validate_message' => 'sms_based#validate_message'
  
end
