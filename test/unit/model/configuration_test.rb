require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  setup do
    @stack = ForemanDeployments::Stack.new(
      :name => 'stack1',
      :definition => 'def'
    )
    @deployment = ForemanDeployments::Deployment.new(
      :name => 'deployment1'
    )
    @valid_params = {
      :description => 'stack1 pre-configuration',
      :stack => @stack,
      :deployment => @deployment
    }
  end

  describe 'validations' do
    test 'valid attributes' do
      c = ForemanDeployments::Configuration.new(@valid_params)
      assert(c.valid?)
    end

    test 'description is not required' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:description))
      assert(c.valid?)
    end

    test 'stack is required' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:stack))
      refute(c.valid?)
    end

    test 'deployment is optional' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:deployment))
      assert(c.valid?)
    end
  end

  describe 'default_description' do
    test 'it mentions the stack when deployment is empty' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:description, :deployment))
      assert_equal('Saved configuration for stack1', c.default_description)
    end

    test 'it mentions the deployment when it is present' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:description))
      assert_equal('Configuration for deployment1', c.default_description)
    end

    test 'it returns nil when neither stack nor deployment is set' do
      c = ForemanDeployments::Configuration.new(@valid_params.except(:description, :deployment, :stack))
      assert_nil(c.default_description)
    end
  end

  describe 'configure' do
    setup do
      @stack.save!
      @conf = ForemanDeployments::Configuration.new(:stack => @stack, :description => 'config')
      @values = {
        :param_a => 1,
        :param_b => {
          :param_c => 2
        }
      }
      @unknown_task = stub(:task_id => 'UnknownTask')
      @some_task = stub(:task_id => 'SomeTask')
    end

    test 'it gives empty hash for unconfigured tasks' do
      assert_equal({}, @conf.get_config_for(@unknown_task))
    end

    test 'it returns configured values' do
      @conf.set_config_for(@some_task, @values)
      assert_equal(@values, @conf.get_config_for(@some_task))
    end

    test 'it saves the values' do
      @conf.set_config_for(@some_task, @values)
      @conf.save

      assert_equal(@values, ForemanDeployments::Configuration.find(@conf.id).get_config_for(@some_task))
    end
  end
end
