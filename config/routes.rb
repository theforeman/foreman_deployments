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
            # ...
          end
        end

        if SETTINGS[:locations_enabled]
          resources :locations, :except => [:new, :edit] do
            # ...
          end
        end

        # ...
      end
    end
  end

end
