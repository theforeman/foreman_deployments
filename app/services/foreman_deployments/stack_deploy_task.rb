#
module ForemanDeployments
  #
  class StackDeployTask < Dynflow::Action
    input_format do
      param :object_type, String
      param :params, Hash
    end

    def plan(description_input)
      # Hash[facts.map {|k, v| [k.to_s, v.to_s]}]
      description = {}
      description_input.each_pair do |k, v|
        description[k] = create_definition(v, description)
      end

      description.values.each(&:validate)
      description.values.each(&:plan)
    end

    private

    def create_definition(task_description, tasks_hash)
      TaskDefinition.new(
        self,
        tasks_hash,
        task_description[:task],
        task_description[:params])
    end
  end
end
