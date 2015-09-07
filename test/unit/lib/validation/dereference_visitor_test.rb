require 'test_helper'

class DereferenceVisitorTest < ActiveSupport::TestCase
  class TestTask < ForemanDeployments::Tasks::BaseDefinition
    def validate
      ForemanDeployments::Validation::ValidationResult.new
    end

    def preliminary_output
      {}
    end
  end

  setup do
    @visitor = ForemanDeployments::Validation::DereferenceVisitor.new
  end

  test 'it resolves dependencies' do
    # We're also testing presence of the cache by setting .expects(:preliminary_output).once
    # and having multiple references to a single task

    task3 = TestTask.new
    task3.expects(:preliminary_output).once.returns('result' => 789)

    task2 = TestTask.new(
      'param1' => 2,
      'param2' => ForemanDeployments::TaskReference.new('task3', 'result', task3)
    )
    task2.expects(:preliminary_output).once.returns('result1' => 123, 'result2' => 456)

    task1 = TestTask.new(
      'param1' => 1,
      'param2' => ForemanDeployments::TaskReference.new('task2', 'result1', task2),
      'param3' => ForemanDeployments::TaskReference.new('task2', 'result2', task2)
    )

    definition = ForemanDeployments::StackDefinition.new(
      'task1' => task1,
      'task2' => task2,
      'task3' => task3
    )
    definition.accept(@visitor)

    assert_equal({}, task3.parameters)
    assert_equal({ 'param1' => 2, 'param2' => 789 }, task2.parameters)
    assert_equal({ 'param1' => 1, 'param2' => 123, 'param3' => 456 }, task1.parameters)
  end
end
