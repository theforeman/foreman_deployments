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
      definitions = {}
      description_input.each_pair do |k, v|
        definitions[k] = create_definition(v, definitions)
      end

      definitions.values.each(&:validate)
      definitions.values.each { |d| d.plan(self) }
    end

    private

    def create_definition(task_description, tasks_hash)
      TaskDefinition.new(
        tasks_hash,
        task_description[:task],
        task_description[:params])
    end
  end
end
