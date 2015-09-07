require 'test_helper'

class ValidationVisitorTest < ActiveSupport::TestCase
  class TestTask < ForemanDeployments::Tasks::BaseDefinition
    def validate
      ForemanDeployments::Validation::ValidationResult.new
    end

    def preliminary_output
      {}
    end
  end

  class TestResource
  end

  def mock_deployment(task_hash)
    task_hash.stubs(:deep_clone).returns(task_hash)
    task_hash
  end

  let(:valid_result) { ForemanDeployments::Validation::ValidationResult.new }

  setup do
    @visitor = ForemanDeployments::Validation::ValidationVisitor.new
  end

  test 'it is valid when there are no tasks' do
    definition = ForemanDeployments::StackDefinition.new
    definition.accept(@visitor)

    assert(@visitor.result.valid?)
  end

  test 'it validates all tasks' do
    valid_task1 = TestTask.new
    valid_task1.expects(:validate).once.returns(valid_result)

    valid_task2 = TestTask.new
    valid_task2.expects(:validate).once.returns(valid_result)

    definition = ForemanDeployments::StackDefinition.new(
      :task1 => valid_task1,
      :task2 => valid_task2
    )
    definition.accept(@visitor)
  end

  test 'it returns messages from all the tasks' do
    valid_task1 = TestTask.new
    valid_task1.expects(:validate).once.returns(valid_result)

    invalid_task2 = TestTask.new
    invalid_task2.expects(:validate).once.returns(
      ForemanDeployments::Validation::ValidationResult.new(:name => 'Name must be unique')
    )

    definition = ForemanDeployments::StackDefinition.new(
      :task1 => valid_task1,
      :task2 => invalid_task2
    )
    definition.accept(@visitor)

    refute(@visitor.result.valid?)
    assert_equal({ 'task2' => { :name => 'Name must be unique' } }, @visitor.result.messages)
  end
end
