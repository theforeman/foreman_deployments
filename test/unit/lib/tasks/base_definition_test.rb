require 'test_helper'

class BaseDefinitionTest < ActiveSupport::TestCase
  describe 'task_id' do
    test "it's nil by default" do
      assert_equal(nil, ForemanDeployments::Tasks::BaseDefinition.new.task_id)
    end

    test 'it enables setting an id' do
      task = ForemanDeployments::Tasks::BaseDefinition.new
      task.task_id = :some_task
      assert_equal(:some_task, task.task_id)
    end
  end

  test 'it returns parameters' do
    expected_params = {
      'a' => 1,
      'b' => 2
    }
    task = ForemanDeployments::Tasks::BaseDefinition.new(expected_params)
    assert_equal(expected_params, task.parameters)
  end

  describe 'plan' do
    let(:task_params) { { :params => true } }
    let(:dynflow_action) { mock }
    let(:parent_task) do
      parent_task = mock
      parent_task.expects(:plan_action).with(dynflow_action, task_params).once.returns(dynflow_action)
      parent_task
    end
    let(:task) do
      task = ForemanDeployments::Tasks::BaseDefinition.new(task_params)
      task.stubs(:dynflow_action).returns(dynflow_action)
      task
    end

    test 'plans action returned from dynflow_action' do
      task.plan(parent_task)
    end

    test 'plans the action only once' do
      task.plan(parent_task)
      task.plan(parent_task)
    end
  end

  test 'validate raises not implemented exception' do
    assert_raises NotImplementedError do
      ForemanDeployments::Tasks::BaseDefinition.new.validate
    end
  end

  test 'dynflow_action raises not implemented exception' do
    assert_raises NotImplementedError do
      ForemanDeployments::Tasks::BaseDefinition.new.dynflow_action
    end
  end

  test 'configure deep merges the parameters' do
    task = ForemanDeployments::Tasks::BaseDefinition.new(
                                                'count' => 1,
                                                'should_not' => 'be_touched',
                                                'parameters' => {
                                                  'a' => 1,
                                                  'b' => 2
                                                }
    )
    parameters = {
      'count' => 2,
      'parameters' => {
        'a' => 1,
        'c' => 3
      }
    }
    expected_params = {
      'count' => 2,
      'should_not' => 'be_touched',
      'parameters' => {
        'a' => 1,
        'b' => 2,
        'c' => 3
      }
    }
    task.configure(parameters)

    assert_equal(expected_params, task.parameters)
  end

  describe 'accept' do
    test 'it calls visit on the visitor with self' do
      definition = ForemanDeployments::Tasks::BaseDefinition.new

      visitor = mock
      visitor.expects(:visit).with(definition).once

      definition.accept(visitor)
    end

    test 'it calls visit on parameters' do
      visitable1 = mock
      visitable2 = mock

      definition = ForemanDeployments::Tasks::BaseDefinition.new(
        :params => {
          :first => 1,
          :second => visitable1,
          :third => [1, 2, visitable2]
        }
      )

      visitor = mock
      visitor.expects(:visit).with(definition).once
      visitable1.expects(:accept).with(visitor).once
      visitable2.expects(:accept).with(visitor).once

      definition.accept(visitor)
    end
  end
end
