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
    resources :graphs, :only => [:index]
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
    resources :jobs, :only => :index
  end

  constraints auth_resque do
    mount Resque::Server, :at => "/admin/resque"
  end
  
  resources :ontologies, only: [:index, :show] do
    collection do
      get 'keywords' => 'ontology_search#keywords'
      get 'search' => 'ontology_search#search'
    end
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

    resources :files, only: [:new, :create]

    # action: history, diff, entries_info, files
    get ':oid/:action(/:path)',
      controller:  :files,
      as:          :oid,
      constraints: { path: /.*/ }
  end

  get ':repository_id(/:path)',
    controller:  :files,
    action:      :files,
    as:          :repository_tree,
    constraints: { path: /.*/ }

  root :to => 'home#show'

end
