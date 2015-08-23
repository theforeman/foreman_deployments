require 'test_helper'

class StackParserTest < ActiveSupport::TestCase
  class Vulnerable
  end

  class TestTask < ForemanDeployments::Tasks::BaseDefinition
  end

  def assert_stack_invalid
    e = assert_raises ForemanDeployments::StackParseException do
      yield
    end
    assert_match(/Stack definition is invalid/, e.message)
  end

  setup do
    @register = ForemanDeployments::TaskRegistry.new
    @parser = ForemanDeployments::StackParser.new(@register)
  end

  test 'it raises exception when the stack is not valid yaml hash' do
    assert_stack_invalid do
      @parser.parse('This is not a valid stack')
    end
  end

  test 'it raises exception when the input is not string' do
    assert_stack_invalid do
      @parser.parse(123)
    end
  end

  test 'it raises exception when the input is nil' do
    assert_stack_invalid do
      @parser.parse(nil)
    end
  end

  test 'it raises exception when the input is empty string' do
    assert_stack_invalid do
      @parser.parse('')
    end
  end

  test 'it raises exception when the stack contains references to unknown tasks' do
    stack = [
      'FirstRun: !task:Unknown',
      '  parameters:',
      '    host_id: 1'
    ].join("\n")
    e = assert_raises ForemanDeployments::UnknownTaskException do
      @parser.parse(stack)
    end
    assert_match(/Unknown stack task Unknown/, e.message)
  end

  test 'it does not allow creation of custom objects' do
    stack = [
      'SatelliteStack: !ruby/object:StackParserTest::Vulnerable',
      '  name: Satellite'
    ].join("\n")
    e = assert_raises ForemanDeployments::UnknownYAMLTagException do
      @parser.parse(stack)
    end
    assert_match(/Unknown YAML tag ruby\/object:StackParserTest::Vulnerable/, e.message)
  end

  test 'it returns instance of StackDefinition' do
    @register.register_task('Test', StackParserTest::TestTask)
    stack = [
      'FirstRun: !task:Test',
      '  parameters:',
      '    host_id: 1'
    ].join("\n")

    stack_definition = @parser.parse(stack)
    assert_equal(ForemanDeployments::StackDefinition, stack_definition.class)
  end

  test 'it parses the stack' do
    @register.register_task('Test', StackParserTest::TestTask)
    stack = [
      'FirstRun: !task:Test',
      '  parameters:',
      '    host_id: 1'
    ].join("\n")

    stack_definition = @parser.parse(stack)

    task_definition = stack_definition.tasks['FirstRun']
    assert_equal(StackParserTest::TestTask, task_definition.class)
    assert_equal('FirstRun', task_definition.task_id)
    assert_equal({ 'parameters' => { 'host_id' => 1 } }, task_definition.parameters)
  end

  test 'it parses references in a stack' do
    @register.register_task('Test', StackParserTest::TestTask)

    stack = [
      'DbServerHost: !task:Test',
      'FirstRun: !task:Test',
      '  parameters:',
      '    host_id: !reference',
      "      object: 'DbServerHost'",
      "      field: 'result.id'"
    ].join("\n")
    stack_definition = @parser.parse(stack)

    assert_equal(StackParserTest::TestTask, stack_definition.tasks['FirstRun'].class)

    reference = stack_definition.tasks['FirstRun'].parameters['parameters']['host_id']
    assert_equal(ForemanDeployments::TaskReference, reference.class)
    assert_equal('DbServerHost', reference.task_id)
    assert_equal(stack_definition.tasks['DbServerHost'], reference.task)
    assert_equal('result.id', reference.output_key)
  end
end
