# This calls the main test_helper in Foreman-core
require 'test_helper'

#
class TestUserTask
  def self.get_validation_object(_)
    ForemanDeployments::ValidationResult.new({}) do
      true
    end
  end

  def plan(_)
  end

  def run
  end
end

class TestUsergroupTask < TestUserTask
end

# Add plugin to FactoryGirl's paths
FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.reload
