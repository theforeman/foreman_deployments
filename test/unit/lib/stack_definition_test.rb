require 'test_helper'

class StackDefinitionTest < ActiveSupport::TestCase
  setup do
    @tasks = {
      'task1' => ForemanDeployments::Tasks::BaseDefinition.new,
      'task2' => ForemanDeployments::Tasks::BaseDefinition.new
    }
  end

  describe 'tasks' do
    test 'returns empty hash by default' do
      definition = ForemanDeployments::StackDefinition.new
      assert_equal({}, definition.tasks)
    end

    test 'it returns tasks' do
      definition = ForemanDeployments::StackDefinition.new(@tasks)

      assert_equal(2, definition.tasks.count)
      assert_equal(@tasks['task1'], definition.tasks['task1'])
      assert_equal(@tasks['task2'], definition.tasks['task2'])
    end

    test 'it sets ids to tasks' do
      definition = ForemanDeployments::StackDefinition.new(@tasks)

      assert_equal('task1', definition.tasks['task1'].task_id)
      assert_equal('task2', definition.tasks['task2'].task_id)
    end
  end

  describe 'accept' do
    test 'it calls visit on the visitor with self' do
      definition = ForemanDeployments::StackDefinition.new

      visitor = mock
      visitor.expects(:visit).with(definition).once

      definition.accept(visitor)
    end

    test 'it calls accept on all tasks' do
      definition = ForemanDeployments::StackDefinition.new(@tasks)

      visitor = mock
      visitor.stubs(:visit)

      definition.tasks['task1'].expects(:accept).with(visitor).once
      definition.tasks['task2'].expects(:accept).with(visitor).once
      definition.accept(visitor)
    end
  end
end
