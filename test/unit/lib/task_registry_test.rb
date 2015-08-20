require 'test_helper'

class TaskRegistryTest < ActiveSupport::TestCase
  class Task1 < ForemanDeployments::Tasks::BaseDefinition; end
  class Task2 < ForemanDeployments::Tasks::BaseDefinition; end

  setup do
    @register = ForemanDeployments::TaskRegistry.new
  end

  test 'it does not contain any tasks by default' do
    assert_equal({}, @register.available_tasks)
  end

  test 'it registers a task' do
    @register.register_task('task1', Task1)
    assert_equal({ 'task1' => Task1 }, @register.available_tasks)
  end

  test 'it registers a task with a symbol tag' do
    @register.register_task(:task1, Task1)
    @register.register_task(:task2, Task2)
    assert_equal({ 'task1' => Task1, 'task2' => Task2 }, @register.available_tasks)
  end

  test 'it does not allow to register a task with empty tag' do
    assert_raises ForemanDeployments::InvalidTaskException do
      @register.register_task('', Task1)
    end
  end

  test 'it does not allow to register a task with nil tag' do
    assert_raises ForemanDeployments::InvalidTaskException do
      @register.register_task(nil, Task1)
    end
  end

  test 'it does not allow to register a task with invalid name' do
    assert_raises ForemanDeployments::InvalidTaskException do
      @register.register_task('[]', Task1)
    end
  end

  test 'it does not allow to register a class that is not child of ForemanDeployments::Tasks::BaseDefinition' do
    assert_raises ForemanDeployments::InvalidTaskException do
      @register.register_task('object', Object)
    end
  end

  test 'it clears registeretd tasks' do
    @register.register_task(:task1, Task1)
    @register.register_task(:task2, Task2)
    @register.clear!
    assert_equal({}, @register.available_tasks)
  end
end
