module ForemanDeployments
  module Tasks
    class UpdateTaskDefinition < ForemanDeployments::Tasks::BaseDefinition
      class Action < BaseAction
        def run
          obj = UpdateTaskDefinition.update_object(input)
          obj.save!
          UpdateTaskDefinition.create_output(obj, output)
        end
      end

      class ResultsWrapper
        attr_reader :result

        def initialize(result)
          @result = result

          @result = [@result] if @result.is_a? ActiveRecord::Base
        end

        def save!
          @result.map(&:save!)
        end

        def valid?
          @result.reduce(true) { |a, e| a && e.valid? }
        end

        def errors
          merged = ActiveModel::Errors.new(@result.first)

          @result.each do |record|
            record.errors.each do |k, v|
              merged[k] = "#{record.class.name}##{record.id}: #{v}"
            end
          end

          merged
        end
      end

      def validate
        obj = self.class.update_object(parameters.configured)
        obj.valid?
        ForemanDeployments::Validation::ValidationResult.new(obj.errors.full_messages)
      rescue ActiveRecord::ActiveRecordError => e
        ForemanDeployments::Validation::ValidationResult.new([e.message])
      end

      def preliminary_output
        self.class.create_output(self.class.update_object(parameters.configured))
      end

      def dynflow_action
        self.class::Action
      end

      def self.update_object(parameters)
        object_type = parameters['class']
        object_ids = parameters['ids']
        object_params = parameters['params'] || {}

        object_type = object_type.constantize if object_type.is_a? String
        objects = object_type.find(object_ids.to_a)

        objects.each do |object|
          object.attributes = object_params
        end

        ResultsWrapper.new objects
      end

      def self.create_output(obj, output_hash = {})
        obj = obj.result
        output_hash['objects'] = obj
        output_hash
      end

      def self.tag_name
        'UpdateResource'
      end
    end
  end
end
