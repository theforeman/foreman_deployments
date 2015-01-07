Rails.application.routes.draw do

  namespace :foreman_deployments do
    namespace :api do
      scope '(:apiv)',
            :module      => :v2,
            :defaults    => { :apiv => 'v2' },
            :apiv        => /v1|v2/,
            :constraints => ApiConstraints.new(:version => 2) do


        if SETTINGS[:organizations_enabled]
          resources :organizations, :except => [:new, :edit] do
            resources :deployments, :except => [:new, :edit]
            resources :stacks, :except => [:new, :edit]
            # scoped by location AND organization
            resources :locations, :except => [:new, :edit] do
              resources :deployments, :except => [:new, :edit]
              resources :stacks, :except => [:new, :edit]
            end
          end
        end

        if SETTINGS[:locations_enabled]
          resources :locations, :except => [:new, :edit] do
            resources :deployments, :except => [:new, :edit]
            resources :stacks, :except => [:new, :edit]
            # scoped by location AND organization
            resources :organizations, :except => [:new, :edit] do
              resources :stacks, :except => [:new, :edit]
            end
          end
        end

        resources :deployments, :except => [:new, :edit]
        resources :stacks, :except => [:new, :edit]
      end
    end
  end

end
