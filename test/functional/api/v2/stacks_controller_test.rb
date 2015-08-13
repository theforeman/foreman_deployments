require 'test_helper'

class ForemanDeployments::Api::V2::StacksControllerTest < ActionController::TestCase
  class FakeTask < ForemanDeployments::Tasks::BaseDefinition
  end

  describe 'importing stack' do
    setup do
      @definition = [
        'FirstRun: !task:Test',
        '  parameters:',
        '    host_id: 1'
      ].join("\n")
    end

    teardown do
      ForemanDeployments.tasks.clear!
    end

    test 'should import stack' do
      ForemanDeployments.tasks.register_task('Test', FakeTask)

      assert_difference('ForemanDeployments::Stack.count', 1) do
        post :create,  :stack => { :name => 'Test stack', :definition => @definition }
      end
      assert_response :success

      parsed_response = JSON.parse(response.body)
      assert_equal('Test stack', parsed_response['name'])
    end

    test 'should complain on invalid stack' do
      assert_difference('ForemanDeployments::Stack.count', 0) do
        post :create,  :stack => { :name => 'Test stack', :definition => @definition }
      end
      assert_response :unprocessable_entity

      parsed_response = JSON.parse(response.body)
      assert_match('Unknown stack task Test', parsed_response['error']['message'])
    end
  end

  describe 'listing stacks' do
    test 'it lists available stacks' do
      get :index
      assert_response :success
    end
  end
end
