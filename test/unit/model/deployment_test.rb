require 'test_plugin_helper'

class DeploymentTest < ActiveSupport::TestCase
  include RegistryStub

  class FakeTask < ForemanDeployments::Tasks::BaseDefinition; end

  setup do
    @stack = FactoryGirl.build(:stack,
                               :organizations => [taxonomies(:organization1)],
                               :locations => [taxonomies(:location1)]
    )
    @config = ForemanDeployments::Configuration.new(
      :description => 'config for deployment1',
      :stack => @stack
    )
    @valid_params = {
      :name => 'deployment1',
      :configuration => @config,
      :organization => taxonomies(:organization1),
      :location => taxonomies(:location1)
    }

    @registry = stub_registry
    @registry.register_task(FakeTask)

    @task = FactoryGirl.build(:foreman_task)
    ForemanTasks.stubs(:async_task).returns(@task)
  end

  describe 'validations' do
    test 'valid attributes' do
      d = ForemanDeployments::Deployment.new(@valid_params)
      assert(d.valid?)
    end

    test 'name must be present' do
      d = ForemanDeployments::Deployment.new(@valid_params.except(:name))
      refute(d.valid?)
    end

    test 'configuration must be present' do
      d = ForemanDeployments::Deployment.new(@valid_params.except(:configuration))
      refute(d.valid?)
    end

    test 'organization must be present' do
      d = ForemanDeployments::Deployment.new(@valid_params.except(:organization))
      refute(d.valid?)
    end

    test "organization must be one of stack's orgs" do
      d = ForemanDeployments::Deployment.new(@valid_params.merge(:organization => taxonomies(:organization2)))
      refute(d.valid?)
    end

    test 'location must be present' do
      d = ForemanDeployments::Deployment.new(@valid_params.except(:location))
      refute(d.valid?)
    end

    test "organization must be one of stack's orgs" do
      d = ForemanDeployments::Deployment.new(@valid_params.merge(:location => taxonomies(:location2)))
      refute(d.valid?)
    end
  end

  describe 'status' do
    setup do
      @deployment = ForemanDeployments::Deployment.new(:task => @task)
    end

    test 'is :configuration when no task exist' do
      @deployment.task = nil
      assert_equal(:configuration, @deployment.status)
    end

    test 'is :running when the task is running' do
      assert_equal(:running, @deployment.status)
    end

    test 'is :paused when the task is paused' do
      @task.state = 'paused'
      @task.result = 'success'
      assert_equal(:paused, @deployment.status)
    end

    test 'is :deployed when the task successfully finished' do
      @task.state = 'stopped'
      @task.result = 'success'
      assert_equal(:deployed, @deployment.status)
    end

    test 'is :failed when the task failed' do
      @task.state = 'stopped'
      @task.result = 'error'
      assert_equal(:failed, @deployment.status)
    end
  end

  describe 'run' do
    test 'it refuses to run a deployment that is already running' do
      deployment = ForemanDeployments::Deployment.new(@valid_params)
      deployment.stubs(:status).returns(:running)
      e = assert_raises Foreman::Exception do
        deployment.run
      end
      assert_match("You can't start a deployment that is already running!", e.message)
    end

    test 'it refuses to run a stack has some validation errors' do
      deployment = ForemanDeployments::Deployment.new(@valid_params)
      deployment.parsed_stack.stubs(:validate!).raises(
        ForemanDeployments::Validation::ValidationError.new({}, 'validation failure')
      )

      assert_raises ForemanDeployments::Validation::ValidationError do
        deployment.run
      end
    end

    test 'it plans a foreman task' do
      deployment = ForemanDeployments::Deployment.new(@valid_params)
      deployment.configuration.set_config_for(stub(:task_id => 'Task1'), 'param1' => '1')
      deployment.configuration.save
      deployment.parsed_stack.stubs(:validate!)

      ForemanTasks.expects(:async_task).with do |main_task, parsed_stack|
        assert_equal(ForemanDeployments::Tasks::StackDeployAction, main_task)
        assert_equal({ 'param1' => '1' }, parsed_stack.tasks['Task1'].configuration)
      end

      deployment.run
    end

    test 'it saves the task id' do
      deployment = ForemanDeployments::Deployment.new(@valid_params)
      deployment.parsed_stack.stubs(:validate!)

      deployment.run
      assert_equal(@task.id, deployment.task_id)
    end
  end

  describe 'stack' do
    test 'returns nil by default' do
      deployment = ForemanDeployments::Deployment.new
      assert_nil(deployment.stack)
    end

    test 'returns stack of the configuration' do
      stack = ForemanDeployments::Stack.new
      config = ForemanDeployments::Configuration.new(:stack => stack)
      deployment = ForemanDeployments::Deployment.new(:configuration => config)

      assert_equal(stack, deployment.stack)
    end
  end
end
