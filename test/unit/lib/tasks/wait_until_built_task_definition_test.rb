require 'test_helper'

class WaitUntilBuiltTaskDefinitionTest < ActiveSupport::TestCase
  let(:definition_class) { ForemanDeployments::Tasks::WaitUntilBuiltTaskDefinition }

  describe 'build' do
    test 'it returns instance of WaitUntilBuiltTaskDefinition' do
      definition = definition_class.build
      assert_equal(ForemanDeployments::Tasks::WaitUntilBuiltTaskDefinition, definition.class)
    end
  end

  describe 'build status' do
    setup do
      @reports = []
      @host = stub(
        :reports => @reports
      )
    end

    test 'is negative for nil' do
      status = definition_class.build_status(nil)
      assert_equal(false, status['build'])
    end

    test 'is negative for host with only one report' do
      @reports << stub(:error? => false)
      status = definition_class.build_status(@host)
      assert_equal(false, status['build'])
    end

    test 'is negative for host with two reports, where the last failed' do
      @reports << stub(:error? => false)
      @reports << stub(:error? => true)
      status = definition_class.build_status(@host)
      assert_equal(false, status['build'])
    end

    test 'is positive for host with two reports, where the last succeeded' do
      @reports << stub(:error? => false)
      @reports << stub(:error? => true)
      @reports << stub(:error? => false)
      status = definition_class.build_status(@host)
      assert_equal(true, status['build'])
    end
  end

  describe 'validation' do
    setup do
      @definition = definition_class.build
    end

    test 'it is valid when a host_id is passed' do
      @definition.configure('host_id' => 1)
      result = @definition.validate

      assert result.valid?
    end

    test 'it is invalid when a host_id is missing' do
      result = @definition.validate
      refute result.valid?
      assert result.messages.include?("'host_id' is a required parameter")
    end
  end

  test 'it returns correct dynflow action' do
    action = definition_class.build.dynflow_action
    assert_equal(ForemanDeployments::Tasks::WaitUntilBuiltTaskDefinition::Action, action)
  end
end
