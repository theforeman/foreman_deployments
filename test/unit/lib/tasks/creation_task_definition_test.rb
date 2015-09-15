require 'test_helper'

class CreationTaskDefinitionTest < ActiveSupport::TestCase
  let(:definition_class) { ForemanDeployments::Tasks::CreationTaskDefinition }

  describe 'build' do
    test 'it returns instance of HostCreationTaskDefinition for Host' do
      definition = definition_class.build('class' => 'Host')
      assert_equal(ForemanDeployments::Tasks::HostCreationTaskDefinition, definition.class)
    end

    test 'it returns instance of HostCreationTaskDefinition for Host::Managed' do
      definition = definition_class.build('class' => 'Host::Managed')
      assert_equal(ForemanDeployments::Tasks::HostCreationTaskDefinition, definition.class)
    end

    test 'it returns instance of HostCreationTaskDefinition for other classes' do
      definition = definition_class.build('class' => 'Architecture')
      assert_equal(ForemanDeployments::Tasks::CreationTaskDefinition, definition.class)
    end
  end

  describe 'object creation' do
    test 'it returns instance of the class' do
      object = definition_class.create_object(
        'class' => 'Architecture'
      )
      assert_equal(Architecture, object.class)
    end

    test 'it sets the parameters' do
      object = definition_class.create_object(
        'class' => 'Architecture',
        'params' => {
          'name' => 'test'
        }
      )
      assert_equal('test', object.name)
    end

    test "it ignores parameters that don't exist" do
      object = definition_class.create_object(
        'class' => 'Architecture',
        'params' => {
          'name' => 'test',
          'unknown' => 123
        }
      )
      assert_equal('test', object.name)
    end
  end

  test 'it returns correct dynflow action' do
    action = definition_class.build('class' => 'Architecture').dynflow_action
    assert_equal(ForemanDeployments::Tasks::CreationTaskDefinition::Action, action)
  end
end
