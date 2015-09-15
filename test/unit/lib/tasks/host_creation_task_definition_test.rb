require 'test_helper'

class HostCreationTaskDefinitionTest < ActiveSupport::TestCase
  let(:definition_class) { ForemanDeployments::Tasks::HostCreationTaskDefinition }

  test 'it returns correct dynflow action' do
    action = definition_class.build('class' => 'Host').dynflow_action
    assert_equal(ForemanDeployments::Tasks::HostCreationTaskDefinition::Action, action)
  end
end
