Rails.application.routes.draw do
  resources :create_resources, module: 'ForemanDeployments'

  namespace :foreman_deployments do
    namespace :api do
      scope '(:apiv)',
            :module      => :v2,
            :defaults    => { :apiv => 'v2' },
            :apiv        => /v1|v2/,
            :constraints => ApiConstraints.new(:version => 2) do
        resources :stacks, :only => [:create]
      end
    end
  end
end
