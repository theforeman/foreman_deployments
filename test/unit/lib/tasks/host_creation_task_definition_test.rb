require 'test_helper'

class HostCreationTaskDefinitionTest < ActiveSupport::TestCase
  let(:definition_class) { ForemanDeployments::Tasks::HostCreationTaskDefinition }

  test 'it returns correct dynflow action' do
    action = definition_class.build('class' => 'Host').dynflow_action
    assert_equal(ForemanDeployments::Tasks::HostCreationTaskDefinition::Action, action)
  end

  describe 'object creation' do
    test 'it applies parameters from a hostgroup' do
      hostgroup = FactoryBot.create(:hostgroup, :with_puppetclass, :with_puppet_orchestration)

      object = definition_class.create_object(
        'class' => 'Host::Managed',
        'params' => {
          'hostgroup_id' => hostgroup.id
        }
      )
      assert_equal(hostgroup.environment_id, object.environment_id)
      assert_equal(hostgroup.puppet_proxy_id, object.puppet_proxy_id)
      assert_equal(hostgroup.puppet_ca_proxy_id, object.puppet_ca_proxy_id)
    end
  end
end
