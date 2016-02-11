module ForemanDeployments
  module Tasks
    class SearchTaskDefinition < BaseDefinition
      class Action < BaseAction
        def run
          results = SearchTaskDefinition.search(input)
          results = SerializableArray.new(results)
          SearchTaskDefinition.create_output(results, output)
        end

        def self.dereference_output(storage, path)
          path.each_with_index do |key, i|
            if i == 0
              if key == 'results'
                storage = storage[:input][:class].constantize.where(:id => storage[:output][:result][:ids])
                next
              else
                storage = storage[:output]
              end
            end
            return nil if storage.nil?
            if storage.is_a?(Hash) || storage.is_a?(Dynflow::ExecutionPlan::OutputReference)
              storage = storage[key]
            else
              storage = storage.send(key)
            end
          end
          storage
        end
      end

      class SerializableArray < Array
        def to_hash
          {}
        end
      end

      def validate
        results = SearchTaskDefinition.search(parameters.configured)
        messages = []
        unless results.any?
          messages = [
            _('%s didn\'t return valid objects') % "#{parameters['class']}.search_for('#{parameters['search_term']}')"]
        end

        ForemanDeployments::Validation::ValidationResult.new(messages)
      end

      def preliminary_output
        SearchTaskDefinition.create_output(SearchTaskDefinition.search(parameters.configured))
      end

      def dynflow_action
        ForemanDeployments::Tasks::SearchTaskDefinition::Action
      end

      def self.search(parameters)
        object_type = parameters['class']
        object_type = object_type.constantize if object_type.is_a? String
        results = object_type.search_for(parameters[:search_term])
        results
      end

      def self.create_output(obj, output_hash = {})
        output_hash['results'] = obj
        output_hash['result'] = { 'ids' => obj.map(&:id) }
        output_hash
      end

      def self.tag_name
        'FindResource'
      end
    end
  end
end
