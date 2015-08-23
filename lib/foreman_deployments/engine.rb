require 'foreman_tasks'
require 'safe_yaml/load'
require 'foreman_deployments/monkey_patches'

module ForemanDeployments
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir["#{config.root}/app/controllers/foreman_deployments/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/foreman_deployments/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/foreman_deployments/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer 'foreman_deployments.load_app_instance_data' do |app|
      app.config.paths['db/migrate'] += ForemanDeployments::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_deployments.register_plugin', after: :finisher_hook do
      Foreman::Plugin.register :foreman_deployments do
        requires_foreman '>= 1.8'

        # Add permissions
        security_block :foreman_deployments do |map|
          map.permission :view_deployments,
                         :"foreman_deployments/api/v2/deployments" => [:index, :show]
          map.permission :create_deployments,
                         :"foreman_deployments/api/v2/deployments" => [:create]
          map.permission :edit_deployments,
                         :"foreman_deployments/api/v2/deployments" => [:update]
          map.permission :destroy_deployments,
                         :"foreman_deployments/api/v2/deployments" => [:destroy]

          map.permission :view_foreman_deployments_stacks,
                         :"foreman_deployments/api/v2/stacks" => [:index, :show, :export]
          map.permission :create_stacks,
                         :"foreman_deployments/api/v2/stacks" => [:create]
          map.permission :edit_stacks,
                         :"foreman_deployments/api/v2/stacks" => [:update]
          map.permission :destroy_stacks,
                         :"foreman_deployments/api/v2/stacks" => [:destroy]
        end

        # Add a new role called 'Discovery' if it doesn't exist
        # role "ForemanDeployments", [:view_foreman_deployments]
      end
    end

    initializer 'foreman_deployments.apipie' do
      # rubocop:disable Metrics/LineLength
      Apipie.configuration.api_controllers_matcher << "#{ForemanDeployments::Engine.root}/app/controllers/foreman_deployments/api/v2/*.rb"
      Apipie.configuration.checksum_path += ['/foreman_deployments/api/']
    end

    initializer 'foreman_deployments.require_dynflow', before: 'foreman_tasks.initialize_dynflow' do
      ::ForemanTasks.dynflow.require!
      ::ForemanTasks.dynflow.config.eager_load_paths << File.join(ForemanDeployments::Engine.root, 'app/services/foreman_deployments/tasks')
    end

    initializer 'foreman_deployments.safe_yaml' do
      SafeYAML::OPTIONS[:default_mode] = :safe
      SafeYAML::OPTIONS[:deserialize_symbols] = true
    end

    # Include concerns in this config.to_prepare block
    # config.to_prepare do
    #   ::Hostgroup.send :include, ForemanDeployments::Concerns::Hostgroup
    #   ::GroupParameter.send :include, ForemanDeployments::Concerns::GroupParameter
    # end

    # config.eager_load_paths += ["#{config.root}/app/models/foreman_deployments/resource/"]

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanDeployments::Engine.load_seed
      end
    end
  end
end
