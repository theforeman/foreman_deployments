require 'foreman_deployments/engine'

module ForemanDeployments
  def self.registry
    @task_registry ||= Tasks::Registry.new
  end

  def self.tasks
    @task_registry ||= Tasks::Registry.new
  end

  def self.inputs
    @input_registry ||= Inputs::Registry.new
  end
end
