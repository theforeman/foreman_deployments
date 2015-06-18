require 'test_helper'

class StackTest < ActiveSupport::TestCase
  describe 'validations' do
    setup do
      @valid_params = {
        :name => 'stack1',
        :definition => 'abc'
      }
    end

    test 'valid attributes' do
      s = ForemanDeployments::Stack.new(@valid_params)
      assert(s.valid?)
    end

    test 'name must be unique' do
      ForemanDeployments::Stack.create(@valid_params)
      s = ForemanDeployments::Stack.new(@valid_params.except(:definition))
      refute(s.valid?)
    end

    test 'name must be present' do
      s = ForemanDeployments::Stack.new(@valid_params.except(:name))
      refute(s.valid?)
    end

    test 'definition must be present' do
      s = ForemanDeployments::Stack.new(@valid_params.except(:definition))
      refute(s.valid?)
    end
  end
end
