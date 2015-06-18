require 'foreman_deployments/engine'

module ForemanDeployments
  def self.tasks
    @task_registry ||= TaskRegistry.new
  end
end
