require 'test_helper'

class RemoveIdsVisitorTest < ActiveSupport::TestCase
  class TestTask < ForemanDeployments::Tasks::BaseDefinition
    def validate
      ForemanDeployments::Validation::ValidationResult.new
    end

    def preliminary_output
      {}
    end
  end

  setup do
    @visitor = ForemanDeployments::Validation::RemoveIdsVisitor.new
  end

  test 'it turns id reference into object reference in parameters' do
    task2 = TestTask.new

    task2_ref = ForemanDeployments::TaskReference.new('task2', 'resource.id')
    task2_ref.task = task2

    task1 = TestTask.new(
      :test_resource_id => task2_ref
    )

    definition = ForemanDeployments::StackDefinition.new(
      'task1' => task1,
      'task2' => task2
    )
    definition.accept(@visitor)

    assert_equal('resource', task1.parameters['test_resource'].output_key)
  end

  test 'it turns single reference to multiple ids into an object reference' do
    task2 = TestTask.new

    task2_ref = ForemanDeployments::TaskReference.new('task2', 'resource.ids')
    task2_ref.task = task2

    task1 = TestTask.new(
      :test_resource_ids => task2_ref
    )

    definition = ForemanDeployments::StackDefinition.new(
      'task1' => task1,
      'task2' => task2
    )
    definition.accept(@visitor)

    assert_equal('resources', task1.parameters['test_resources'].output_key)
  end

  test 'it turns array of id references into array of object references in parameters' do
    task2 = TestTask.new

    task2_ref = ForemanDeployments::TaskReference.new('task2', 'resource.id')
    task2_ref.task = task2

    task1 = TestTask.new(
      :test_resource_ids => [task2_ref]
    )

    definition = ForemanDeployments::StackDefinition.new(
      'task1' => task1,
      'task2' => task2
    )
    definition.accept(@visitor)

    assert_equal(1, task1.parameters['test_resources'].size)
    assert_equal('resource', task1.parameters['test_resources'][0].output_key)
  end

  test 'it does not change parameters that are not references' do
    params = {
      'test_resource_id' => 1,
      'test_resource_ids' => [1, 2]
    }
    task1 = TestTask.new(params)

    definition = ForemanDeployments::StackDefinition.new(
      'task1' => task1
    )
    definition.accept(@visitor)

    assert_equal(params, task1.parameters)
  end
end
