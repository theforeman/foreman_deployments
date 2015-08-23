require 'test_helper'
require 'dynflow/testing'

class StackDeployActionTest < ActiveSupport::TestCase
  include ::Dynflow::Testing

  class TestTaskDefinition < ForemanDeployments::Tasks::BaseDefinition
    class Action < ForemanDeployments::Tasks::BaseAction; end

    def dynflow_action
      Action
    end
  end

  def get_planned_params(task)
    task.planned.plan_input[0]
  end

  describe 'plan' do
    test 'plans actions in deployment' do
      stack = ForemanDeployments::StackDefinition.new(
        :task1 => TestTaskDefinition.new,
        :task2 => TestTaskDefinition.new,
        :task3 => TestTaskDefinition.new
      )

      stack.tasks.each do |_task_id, task|
        task.expects(:plan).once
      end

      create_and_plan_action(ForemanDeployments::Tasks::StackDeployAction, stack)
    end

    test 'planned actions recieve dereferenced input' do
      task3 = TestTaskDefinition.new({})
      task2 = TestTaskDefinition.new(
        :param => ForemanDeployments::TaskReference.new(:task3, :id, task3)
      )
      task1 = TestTaskDefinition.new(
        :param => ForemanDeployments::TaskReference.new(:task2, :some_value, task2)
      )

      stack = ForemanDeployments::StackDefinition.new(
        :task1 => task1,
        :task2 => task2,
        :task3 => task3
      )

      create_and_plan_action(ForemanDeployments::Tasks::StackDeployAction, stack)

      task_params = get_planned_params(task1)
      assert_equal(Dynflow::ExecutionPlan::OutputReference, task_params[:param].class)
      assert_equal(['some_value'], task_params[:param].subkeys)

      task_params = get_planned_params(task2)
      assert_equal(Dynflow::ExecutionPlan::OutputReference, task_params[:param].class)
      assert_equal(['id'], task_params[:param].subkeys)

      assert_equal({}, get_planned_params(task3))
    end

    test 'plans referenced tasks only once' do
      task2 = TestTaskDefinition.new({})
      task1 = TestTaskDefinition.new(
        :param => ForemanDeployments::TaskReference.new(:task2, :some_value, task2)
      )

      stack = ForemanDeployments::StackDefinition.new(
        :task1 => task1,
        :task2 => task2
      )

      planned = mock
      planned.stubs(:output)

      stack.tasks.each do |_task_id, task|
        task.expects(:plan).once.returns(planned)
      end

      create_and_plan_action(ForemanDeployments::Tasks::StackDeployAction, stack)
    end
  end
end
