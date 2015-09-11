require 'test_helper'

class ConfiguratorTest < ActiveSupport::TestCase
  class TestTask < ForemanDeployments::Tasks::BaseDefinition; end

  setup do
    @task1 = TestTask.new
    @task2 = TestTask.new

    @stack_definition = ForemanDeployments::StackDefinition.new(
      'task1' => @task1,
      'task2' => @task2
    )

    @config = mock
    @config.stubs(:get_config_for).with(@task1).returns('key1' => 'value1')
    @config.stubs(:get_config_for).with(@task2).returns('key2' => 'value2')

    @config2 = mock
    @config2.stubs(:get_config_for).with(@task1).returns('key2' => 'value2')
    @config2.stubs(:get_config_for).with(@task2).returns('key2' => 'updated_value2', 'key3' => 'value3')

    @configurator = ForemanDeployments::Config::Configurator.new(@stack_definition)
  end

  describe 'configure' do
    it 'configures the stack' do
      @configurator.configure(@config)

      assert_equal({ 'key1' => 'value1' }, @task1.configuration)
      assert_equal({ 'key2' => 'value2' }, @task2.configuration)
    end

    it 'overwrites the previous config' do
      @task1.configure('key1' => 'previous_value1', 'some_key' => 'value_value')
      @task2.configure('key2' => 'previous_value2', 'some_key' => 'value_value')

      @configurator.configure(@config)

      assert_equal({ 'key1' => 'value1' }, @task1.configuration)
      assert_equal({ 'key2' => 'value2' }, @task2.configuration)
    end
  end

  describe 'merge' do
    it 'loads the config and merges the update' do
      @configurator.merge(@config, @config2)

      assert_equal({ 'key1' => 'value1', 'key2' => 'value2' }, @task1.configuration)
      assert_equal({ 'key2' => 'updated_value2', 'key3' => 'value3' }, @task2.configuration)
    end
  end

  describe 'dump' do
    it 'saves the stack configuration' do
      @task1.stubs(:configuration).returns(:a => 1)
      @task2.stubs(:configuration).returns(:b => 2)

      config = ForemanDeployments::Configuration.new
      @configurator.dump(config)

      assert_equal({ :a => 1 }, config.get_config_for(@task1))
      assert_equal({ :b => 2 }, config.get_config_for(@task2))
    end
  end
end
