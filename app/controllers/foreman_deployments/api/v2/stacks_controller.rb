module ForemanDeployments
  module Api
    module V2
      class StacksController < BaseController
        before_filter :find_resource, :only => [:show, :update]

        def_param_group :stack do
          param :stack, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true, :desc => N_('Name for the stack')
            param :definition, String, :required => true, :desc => N_('Stack definition in YAML format')
          end
        end

        api :POST, '/stacks/', N_('Import a stack')
        param_group :stack, :as => :create
        def create
          @stack = Stack.new(params[:stack])
          # parse the stack to see if it's valid
          ForemanDeployments::StackParser.parse(@stack.definition)
          process_response @stack.save
        end

        api :PUT, '/stacks/:id/', N_('Update imported stack')
        param_group :stack, :as => :update
        param :id, :identifier, :required => true
        def update
          if !@stack.configurations.empty? && !params[:stack][:definition].nil?
            render :json => { :error => _("Can't update stack that has been configured") }, :status => :unprocessable_entity
          else
            ForemanDeployments::StackParser.parse(params[:stack][:definition]) if params[:stack][:definition]
            process_response @stack.update_attributes(params[:stack])
          end
        end

        api :GET, '/stacks/', N_('List saved stacks')
        def index
          @stacks = resource_scope
        end

        api :GET, '/stacks/:id/', N_('Get information about a stack')
        param :id, :identifier, :required => true
        def show
          @parsed_stack = ForemanDeployments::StackParser.parse(@stack.definition)
        end
      end
    end
  end
end
