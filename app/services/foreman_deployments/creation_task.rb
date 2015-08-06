module ForemanDeployments
  #
  class CreationTask < Dynflow::Action
    input_format do
      param :object_type, String
      param :params, Hash
    end

    def self.get_validation_object(params)
      object_type = params[:klass]
      object_params = params[:params]
      obj = create_object(object_type, object_params)
      output = create_output({}, object_type, obj)

      ValidationResult.new output do |out|
        validated = out[:object_id]
        throw validated.errors.full_messages.join(', ') unless validated.valid?
      end
    end

    def plan(params)
      object_type = params[:klass]
      object_params = params[:params]
      plan_self object_type: object_type.name, params: object_params
    end

    def run
      obj = create_object
      obj.save!

      CreationTask.create_output(output, input[:object_type], obj.id)
    end

    private

    def self.create_object(object_type, params)
      object_type = object_type.constantize if object_type.is_a? String
      object_type.new params
    end

    def create_object(object_type = input[:object_type],
                      params = input[:params])
      CreationTask.create_object(object_type, params)
    end

    def self.create_output(hash, obj_type, obj_id)
      hash[:object_type] = obj_type
      hash[:object_id] = obj_id
      hash
    end
  end
end
