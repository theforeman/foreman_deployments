require 'test_helper'

class ForemanDeployments::Api::V2::DeploymentsControllerTest < ActionController::TestCase
  class FakeTask < ForemanDeployments::Tasks::BaseDefinition
  end

  describe 'creating a deployment' do
    setup do
      @stack = ForemanDeployments::Stack.create(
        :name => 'stack1',
        :definition => 'SomeTask:!Task'
      )
      @deployment_params = { :name => 'A Deployment', :stack_id => @stack.id }
    end

    test 'it creates a deployment' do
      assert_difference('ForemanDeployments::Deployment.count', 1) do
        post :create,  :deployment => @deployment_params
      end
      assert_response :success

      parsed_response = JSON.parse(response.body)
      assert_equal('A Deployment', parsed_response['name'])
    end

    test 'it creates configuration for the deployment' do
      assert_difference('ForemanDeployments::Configuration.count', 1) do
        post :create,  :deployment => @deployment_params
      end
      assert_response :success
    end

    test 'should complain when a name is missing' do
      assert_difference('ForemanDeployments::Stack.count', 0) do
        post :create, :deployment => @deployment_params.except(:name)
      end
      assert_response :unprocessable_entity
      parsed_response = JSON.parse(response.body)

      assert_includes(parsed_response['error']['full_messages'], 'Name can\'t be blank')
    end

    test 'should complain when a stack is missing' do
      assert_difference('ForemanDeployments::Stack.count', 0) do
        post :create, :deployment => @deployment_params.except(:stack_id)
      end
      assert_response :unprocessable_entity
      parsed_response = JSON.parse(response.body)

      assert_includes(parsed_response['error']['full_messages'], 'Stack can\'t be blank')
    end
  end

  describe 'listing deployments' do
    test 'it lists deployments' do
      get :index
      assert_response :success
    end
  end

  describe 'configuring deployments' do
    setup do
      @stack = ForemanDeployments::Stack.create(
        :name => 'stack1',
        :definition => [
          'Task1: !task:FakeTask',
          'Task2: !task:FakeTask'
        ].join("\n")
      )
      @deployment = ForemanDeployments::Deployment.create(
        :name => 'deployment1',
        :configuration => ForemanDeployments::Configuration.new(:stack => @stack)
      )
      ForemanDeployments.registry.register_task(FakeTask)
    end

    teardown do
      ForemanDeployments.registry.clear!
    end

    test 'it configures the value' do
      task1_config = {
        'organization_id' => '1',
        'location_id' => '2'
      }
      task2_config = {
        'organization_id' => '3',
        'location_id' => '4'
      }
      values = {
        :Task1 => task1_config,
        :Task2 => task2_config
      }

      put :configuration, :id => @deployment.id, :values => values
      assert_response :success

      @deployment.reload
      assert_equal(task1_config, @deployment.configuration.get_config_for(stub(:task_id => 'Task1')))
      assert_equal(task2_config, @deployment.configuration.get_config_for(stub(:task_id => 'Task2')))
    end
  end
end
