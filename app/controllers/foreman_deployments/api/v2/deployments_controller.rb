module ForemanDeployments
  module Api
    module V2
      class DeploymentsController < BaseController
        include ::Api::TaxonomyScope
        include Parameters::Deployment

        before_action :find_resource, :only => [:show, :replace_configuration, :merge_configuration, :run]

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
          model_params = deployment_params.to_h.with_indifferent_access
          if model_params[:stack_id]
            stack = ForemanDeployments::Stack.authorized(:view_stacks).find(model_params.delete(:stack_id))
          end
          model_params[:configuration] = ForemanDeployments::Configuration.new(:stack => stack)

          @deployment = ForemanDeployments::Deployment.new(model_params)
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

          config = @deployment.configurator
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

          config = @deployment.configurator
          config.configure(new_configuration)
          config.dump(@deployment.configuration)

          @deployment.configuration.save!
        end

        api :GET, '/deployments/:id/', N_('Get information about a deployment')
        param :id, :identifier, :required => true
        def show
          config = @deployment.configurator
          config.configure(@deployment.configuration)

          @validation_result = @deployment.parsed_stack.validate
        end

        api :POST, '/deployments/:id/run/', N_('Start a deployment')
        param :id, :identifier, :required => true
        def run
          @deployment.run
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
