require 'test_helper'

class SearchTaskDefinitionTest < ActiveSupport::TestCase
  class DummyModel < ActiveRecord::Base
  end

  setup do
    @params = {
      'class' => 'SearchTaskDefinitionTest::DummyModel',
      'search_term' => 'a = b'
    }
    @params = HashWithIndifferentAccess[@params]
  end

  describe 'validate' do
    test 'fails, if could not find a matching object' do
      task = ForemanDeployments::Tasks::SearchTaskDefinition.new(@params)
      DummyModel.expects(:search_for).returns([])

      result = task.validate

      assert_equal(1, result.messages.count)
      assert_match(
        "SearchTaskDefinitionTest::DummyModel.search_for('a = b') didn't return valid objects",
        result.messages.first
      )
    end

    test 'succeeds, if there is at least one matching object' do
      task = ForemanDeployments::Tasks::SearchTaskDefinition.new(@params)
      DummyModel.expects(:search_for).returns([mock('DummyModel1')])

      result = task.validate

      assert result.valid?
    end
  end

  test 'should return valid search results for validation process' do
    task = ForemanDeployments::Tasks::SearchTaskDefinition.new(@params)
    search_result1 = mock('DummyModel1')
    search_result1.expects(:id).returns(1)
    DummyModel.expects(:search_for).returns([search_result1])

    result = task.preliminary_output

    assert_equal [search_result1], result['results']
  end
end
