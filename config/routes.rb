Rails.application.routes.draw do
    # ADMINOS ROUTES START

    devise_for :users, skip: :omniauth_callbacks,
      controllers: { sessions: 'users/sessions'}


    devise_for :users, skip: [:session, :password, :registration, :confirmation],
      controllers: { omniauth_callbacks: 'authentications' }

    devise_scope :user do
      get 'authentications/new', to: 'authentications#new'
      post 'authentications/link', to: 'authentications#link'
    end


  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
  namespace :admin do
    resources :features, except: :show do
      collection { post :batch_action }
      member { put :drop }
      member { post :duplication }
    end

    resources :polls, except: :show do
      collection { post :batch_action }
      member { post :duplication }
    end

    resources :articles, except: :show do
      collection { post :batch_action }
      member { post :duplication }
    end

      resources :helps, only: :index
      resource  :settings, only: [:edit, :update]
      resource  :profile, only: [:edit, :update]
      resource  :profile, only: [] do
        member { post :toggle_two_factor }
      end

      resources :users, except: :show do
        collection { post :batch_action }
      end

      resources :versions, only: [:index, :show] do
        collection { post :batch_action }
      end

      resources :pages, except: :show do
        collection { post :batch_action }
        member { put :drop }
        member { post :duplication }
      end

      root to: 'pages#index', as: :root
    end

    root to: 'index#index'
  end

    begin
      Page.for_routes.group_by(&:behavior).each do |behavior, pages|
        pages.each do |page|
          case behavior
          when nil
          else
            resource( "#{page.class.name.underscore}_#{page.id}",
                      path:       page.absolute_path,
                      controller: behavior,
                      only:       :show,
                      page_id:    page.id )
          end
        end
      end
    rescue
      nil
    end

    # ADMINOS ROUTES END
    devise_for :users, skip: :all

    root to: 'index#index'
    resources :features, only: [:show]
    resources :articles do
      resources :comments
    end

    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
