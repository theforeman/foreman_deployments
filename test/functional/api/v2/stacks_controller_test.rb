require 'test_helper'

class ForemanDeployments::Api::V2::StacksControllerTest < ActionController::TestCase
  class FakeTask < ForemanDeployments::Tasks::BaseDefinition
  end

  setup do
    @definition = [
      'FirstRun: !task:FakeTask',
      '  parameters:',
      '    host_id: 1'
    ].join("\n")

    @registry = ForemanDeployments::Registry.new
    ForemanDeployments.stubs(:registry).returns(@registry)
    @registry.register_task(FakeTask)
  end

  describe 'importing stack' do
    test 'should import stack' do
      assert_difference('ForemanDeployments::Stack.count', 1) do
        post :create,  :stack => { :name => 'Test stack', :definition => @definition }
      end
      assert_response :success

      parsed_response = JSON.parse(response.body)
      assert_equal('Test stack', parsed_response['name'])
    end

    test 'should complain on invalid stack' do
      @registry.clear!
      assert_difference('ForemanDeployments::Stack.count', 0) do
        post :create,  :stack => { :name => 'Test stack', :definition => @definition }
      end
      assert_response :unprocessable_entity

      parsed_response = JSON.parse(response.body)
      assert_match('Unknown stack task FakeTask', parsed_response['error']['message'])
    end
  end

  describe 'updating stacks' do
    setup do
      @updated_definition = [
        'AnotherRun: !task:FakeTask'
      ].join("\n")
      @stack = ForemanDeployments::Stack.create(:name => 'Test Stack', :definition => @definition)
    end

    test 'stacks without configuration are editable' do
      put :update, :id => @stack.id, :stack => { :name => 'Updated name', :definition => @updated_definition }
      assert_response :success

      @stack.reload
      assert_equal('Updated name', @stack.name)
      assert_equal(@updated_definition, @stack.definition)
    end

    describe 'with saved configuration' do
      setup do
        @stack.configurations.create!
      end

      test 'it allows to update attributes other than definition' do
        put :update, :id => @stack.id, :stack => { :name => 'Updated name' }
        assert_response :success

        @stack.reload
        assert_equal('Updated name', @stack.name)
      end

      test 'it fails if the definition would be updated' do
        put :update, :id => @stack.id, :stack => { :definition => @updated_definition }
        assert_response :unprocessable_entity

        parsed_response = JSON.parse(response.body)
        assert_match('Can\'t update stack that has been configured', parsed_response['error'])

        @stack.reload
        assert_equal('Test Stack', @stack.name)
        assert_equal(@definition, @stack.definition)
      end
    end

    test 'it fails if the new stack definition is invalid' do
      @registry.clear!

      put :update, :id => @stack.id, :stack => { :definition => @updated_definition }
      assert_response :unprocessable_entity

      parsed_response = JSON.parse(response.body)
      assert_match('Unknown stack task FakeTask', parsed_response['error']['message'])

      @stack.reload
      assert_equal('Test Stack', @stack.name)
      assert_equal(@definition, @stack.definition)
    end
  end

  describe 'listing stacks' do
    test 'it lists available stacks' do
      get :index
      assert_response :success
    end
  end
end
