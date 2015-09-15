Rails.application.routes.draw do
  resources :create_resources, module: 'ForemanDeployments'

  scope :module => :foreman_deployments do
    namespace :api do
      scope '(:apiv)',
            :module      => :v2,
            :defaults    => { :apiv => 'v2' },
            :apiv        => /v1|v2/,
            :constraints => ApiConstraints.new(:version => 2) do
        resources :stacks, :only => [:create, :update, :index, :show]
        resources :deployments, :only => [:create, :index, :show] do
          put :configuration, :on => :member, :to => :replace_configuration
          post :configuration, :on => :member, :to => :merge_configuration
          post :run, :on => :member
        end
      end
    end
  end
end
