require 'test_helper'

class RegistryTest < ActiveSupport::TestCase
  class Task < ForemanDeployments::Tasks::BaseDefinition; end
  class Input < ForemanDeployments::Inputs::BaseInputDefinition; end

  def named(klass, name)
    klass.stubs(:tag_name).returns(name)
    klass
  end

  def task_named(name)
    named(Task, name)
  end

  def input_named(name)
    named(Input, name)
  end

  setup do
    @register = ForemanDeployments::Registry.new
  end

  test 'it does not contain any tasks by default' do
    assert_equal({}, @register.available_tasks)
  end

  test 'it raises exception for invalid type' do
    e = assert_raises ForemanDeployments::Registry::TypeException do
      @register.register('some_type', task_named('task1'))
    end
    assert_match('Type needs to be one of: task, input', e.message)
  end

  test 'it clears registeretd items' do
    @register.register_task(task_named(:task1))
    @register.register_task(task_named(:task2))
    @register.register_input(input_named(:input1))
    @register.clear!
    assert_equal({}, @register.available_tasks)
    assert_equal({}, @register.available_inputs)
  end

  describe 'tasks' do
    test 'it registers a task' do
      @register.register_task(task_named('task1'))
      assert_equal({ 'task1' => 'RegistryTest::Task' }, @register.available_tasks)
    end

    test 'it registers a task with a symbol tag' do
      @register.register_task(task_named(:task1))
      @register.register_task(task_named(:task2))
      assert_equal({ 'task1' => 'RegistryTest::Task', 'task2' => 'RegistryTest::Task' }, @register.available_tasks)
    end

    test 'it does not allow to register a task with empty tag' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_task(task_named(''))
      end
    end

    test 'it does not allow to register a task with nil tag' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_task(task_named(nil))
      end
    end

    test 'it does not allow to register a task with invalid name' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_task(task_named('[]'))
      end
    end

    test 'it does not allow to register a class that is not child of ForemanDeployments::Tasks::BaseDefinition' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_task(Object)
      end
    end
  end

  describe 'inputs' do
    test 'it registers an input' do
      @register.register_input(input_named('input1'))
      assert_equal({ 'input1' => 'RegistryTest::Input' }, @register.available_inputs)
    end

    test 'it registers an input with a symbol tag' do
      @register.register_input(input_named(:input1))
      @register.register_input(input_named(:input2))
      assert_equal({ 'input1' => 'RegistryTest::Input', 'input2' => 'RegistryTest::Input' }, @register.available_inputs)
    end

    test 'it does not allow to register an input with empty tag' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_input(input_named(''))
      end
    end

    test 'it does not allow to register an input with nil tag' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_input(input_named(nil))
      end
    end

    test 'it does not allow to register an input with invalid name' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_input(input_named('[]'))
      end
    end

    test 'it does not allow to register a class that is not child of ForemanDeployments::Inputs::BaseInputDefinition' do
      assert_raises ForemanDeployments::Registry::TypeException do
        @register.register_input(Object)
      end
    end
  end
end
