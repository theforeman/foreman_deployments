require 'foreman_deployments/engine'

module ForemanDeployments
  def self.registry
    @task_registry ||= ForemanDeployments::Registry.new
  end
end
