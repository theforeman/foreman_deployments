require 'test_helper'

class UpdateTaskDefinitionTest < ActiveSupport::TestCase
  describe 'ResultsWrapper' do
    describe 'single record' do
      setup do
        @result = User.new
        @wrapper = ForemanDeployments::Tasks::UpdateTaskDefinition::ResultsWrapper.new @result
      end

      test 'saves record' do
        @result.expects :save!

        @wrapper.save!
      end

      test 'validates record' do
        @result.expects :valid?

        @wrapper.valid?
      end

      test 'shows errors from a record' do
        refute @result.valid?

        errors = @wrapper.errors

        assert_not_empty errors
      end
    end

    describe 'multiple records' do
      setup do
        @result1 = User.first
        @result2 = User.second
        @wrapper = ForemanDeployments::Tasks::UpdateTaskDefinition::ResultsWrapper.new [@result1, @result2]
      end

      test 'saves record' do
        @result1.expects :save!
        @result2.expects :save!

        @wrapper.save!
      end

      test 'validates record' do
        @result1.expects(:valid?).returns(true)
        @result2.expects(:valid?).returns(true)

        @wrapper.valid?
      end

      test 'shows errors from a record' do
        @result1.login = nil
        @result2.login = nil
        refute @result1.valid?
        refute @result2.valid?

        errors = @wrapper.errors

        assert_not_empty errors.find { |_, v| /#{@result1.id}/ =~ v }
        assert_not_empty errors.find { |_, v| /#{@result2.id}/ =~ v }
      end
    end
  end

  describe 'update_object' do
    test 'sets attributes on object with given id' do
      params = {
        'class' => 'User',
        'ids' => [User.first.id, User.second.id],
        'params' => {
          'lastname' => 'test_last_name'
        }
      }

      results = ForemanDeployments::Tasks::UpdateTaskDefinition.update_object(params)

      assert_equal 'test_last_name', results.result.first.lastname
    end
  end

  describe 'validation' do
    setup do
      @params = {
        'class' => 'User',
        'ids' => [User.first.id],
        'params' => {
          'lastname' => 'test_last_name'
        }
      }
    end

    test 'fails if the object fails validation' do
      @params['params']['login'] = nil
      definition = ForemanDeployments::Tasks::UpdateTaskDefinition.new @params

      result = definition.validate

      assert_equal 1, result.messages.count
    end

    test 'succeeds if the object allows such modification' do
      definition = ForemanDeployments::Tasks::UpdateTaskDefinition.new @params

      result = definition.validate

      assert result.valid?
    end
  end

  test 'preliminary_output creates an output with updated object' do
    params = {
      'class' => 'User',
      'ids' => [User.first.id],
      'params' => {
        'lastname' => 'test_last_name'
      }
    }

    definition = ForemanDeployments::Tasks::UpdateTaskDefinition.new params

    result = definition.preliminary_output

    assert_equal User.first.id, result['objects'].first.id
    assert_equal 'test_last_name', result['objects'].first.lastname
  end
end
