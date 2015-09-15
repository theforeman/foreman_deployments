require 'test_helper'

class ValueTest < ActiveSupport::TestCase
  setup do
    @input = ForemanDeployments::Inputs::Value.new(
      'description' => 'Some description',
      'default' => 123
    )
  end

  test 'description' do
    assert_equal('Some description', @input.description)
  end

  describe 'configured' do
    test 'configured provides default when no custom value is set' do
      assert_equal(123, @input.configured)
    end

    test 'configured provides custom value if it was set' do
      @input.configure(456)
      assert_equal(456, @input.configured)
    end
  end

  describe 'to_hash' do
    setup do
      @expected = {
        '_type' => 'input',
        '_name' => 'Value',
        'description' => 'Some description',
        'default' => 123,
        'value' => nil
      }
    end

    test 'contains all the information' do
      assert_equal(@expected, @input.to_hash)
    end

    test 'reflects configuration' do
      @expected['value'] = 456
      @input.configure(456)
      assert_equal(@expected, @input.to_hash)
    end
  end
end
