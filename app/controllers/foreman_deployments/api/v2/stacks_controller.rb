module ForemanDeployments
  module Api
    module V2
      class StacksController < BaseController
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

        api :GET, '/stacks/', N_('List saved stacks')
        def index
          @stacks = resource_scope
        end
      end
    end
  end
end
