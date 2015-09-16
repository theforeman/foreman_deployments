# This calls the main test_helper in Foreman-core
require 'test_helper'

module RegistryStub
  def stub_registry
    registry = ForemanDeployments::Registry.new
    ForemanDeployments.stubs(:registry).returns(registry)
    registry
  end
end

# Add plugin to FactoryGirl's paths
FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.reload
