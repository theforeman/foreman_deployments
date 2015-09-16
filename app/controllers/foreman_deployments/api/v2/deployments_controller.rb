module ForemanDeployments
  module Api
    module V2
      class DeploymentsController < BaseController
        include ::Api::TaxonomyScope

        before_filter :find_resource, :only => [:show, :replace_configuration, :merge_configuration, :run]

        rescue_from ForemanDeployments::Config::InvalidValueException, :with => :unprocessable_entity_error
        rescue_from ForemanDeployments::Validation::ValidationError, :with => :unprocessable_entity_error

        def_param_group :deployment do
          param :deployment, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true, :desc => N_('Name for the deployment')
            param :stack_id, :identifier, :required => true, :desc => N_('Id of the stack to deploy')
          end
        end

        api :POST, '/deployments/', N_('Create a deployment')
        param_group :deployment, :as => :create
        def create
          deployment_params = params[:deployment]

          if deployment_params[:stack_id]
            stack = ForemanDeployments::Stack.authorized(:view_stacks).find(deployment_params.delete(:stack_id))
          end
          deployment_params[:configuration] = ForemanDeployments::Configuration.new(:stack => stack)

          @deployment = ForemanDeployments::Deployment.new(deployment_params)
          process_response @deployment.save
        end

        api :GET, '/deployments/', N_('List deployments')
        api :GET, '/locations/:location_id/deployments/', N_('List of deployments per location')
        api :GET, '/organizations/:organization_id/deployments/', N_('List of deployments per organization')
        param_group :taxonomy_scope, ::Api::V2::BaseController
        param_group :search_and_pagination, ::Api::V2::BaseController
        def index
          @deployments = resource_scope_for_index
        end

        api :POST, '/deployments/:id/configuration/', N_('Merge a configuration update with current values')
        param :id, :identifier, :required => true
        param :values, Hash,
              :required => true,
              :desc => N_('Hash with configuration update for tasks (Format: task ID => configuration values).')
        def merge_configuration
          configuration_update = ForemanDeployments::Configuration.new(:values => params[:values])

          config = ForemanDeployments::Config::Configurator.new(@deployment.parsed_stack)
          config.merge(@deployment.configuration, configuration_update)
          config.dump(@deployment.configuration)

          @deployment.configuration.save!
        end

        api :PUT, '/deployments/:id/configuration/', N_('Configure a deployment')
        param :id, :identifier, :required => true
        param :values, Hash,
              :required => true,
              :desc => N_('Hash with configuration for tasks (Format: task ID => configuration values).')
        def replace_configuration
          new_configuration = ForemanDeployments::Configuration.new(:values => params[:values])

          config = ForemanDeployments::Config::Configurator.new(@deployment.parsed_stack)
          config.configure(new_configuration)
          config.dump(@deployment.configuration)

          @deployment.configuration.save!
        end

        api :GET, '/deployments/:id/', N_('Get information about a deployment')
        param :id, :identifier, :required => true
        def show
          config = ForemanDeployments::Config::Configurator.new(@deployment.parsed_stack)
          config.configure(@deployment.configuration)

          # TODO: show deployment status (config, invalid, deploying, [reverting], deployed)
          @validation_result = ForemanDeployments::Validation::Validator.validate(@deployment.parsed_stack)
        end

        api :POST, '/deployments/:id/run/', N_('Start a deployment')
        param :id, :identifier, :required => true
        def run
          # configure with user input
          config = ForemanDeployments::Config::Configurator.new(@deployment.parsed_stack)
          config.configure(@deployment.configuration)

          # validate
          ForemanDeployments::Validation::Validator.validate!(@deployment.parsed_stack)

          ForemanTasks.async_task(Tasks::StackDeployAction, @deployment.parsed_stack)
        end

        private

        def action_permission
          case params[:action]
          when 'merge_configuration', 'replace_configuration'
            'create'
          when 'run'
            'run'
          else
            super
          end
        end
      end
    end
  end
end
