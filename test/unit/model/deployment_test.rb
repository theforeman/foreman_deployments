require 'test_helper'

class DeploymentTest < ActiveSupport::TestCase
  describe 'validations' do
    setup do
      @stack = ForemanDeployments::Stack.create(
        :name => 'stack1',
        :definition => 'SomeTask:!Task',
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
    end

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
