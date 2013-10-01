require 'resque/server'

auth_resque = ->(request) {
  request.env['warden'].authenticate? and request.env['warden'].user.admin?
}

Ontohub::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
  resources :keys, except: [:show, :edit, :update]
  
  resources :logics do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end
  
  resources :languages do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end
  
  resources :language_mappings
  resources :logic_mappings

  resources :language_adjoints
  resources :logic_adjoints

  resources :serializations

  namespace :admin do
    resources :teams, :only => :index
    resources :users
  end

  constraints auth_resque do
    mount Resque::Server, :at => "/admin/resque"
  end
  
  resources :ontologies, only: [:index, :show] do
    resources :children, :only => :index
    resources :entities, :only => :index
    resources :sentences, :only => :index
    resources :ontology_versions, :only => [:index, :show, :new, :create], :path => 'versions' do
      resource :oops_request, :only => [:show, :create]
    end

#	%w( entities sentences ).each do |name|
#	  get "versions/:number/#{name}" => "#{name}#index", :as => "ontology_version_#{name}"
#	end

    resources :metadata, :only => [:index, :create, :destroy]
    resources :comments, :only => [:index, :create, :destroy]
  end
  
  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'
  get 'symbols'      => 'search#index'

  resources :repositories do
    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :ontologies do
      get 'bulk', :on => :collection
    end
  end

  get '/repositories/:id/:oid(/:path)', controller: :repositories,
                      action: :files,
                      constraints: { path: /.*/ },
                      as: :repository_files_by_oid

  get '/:id(/:path)', controller: :repositories,
                      action: :files,
                      constraints: { path: /.*/ },
                      as: :repository_files

  root :to => 'home#show'

end
