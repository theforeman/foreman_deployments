require 'test_helper'

class ValidationResultTest < ActiveSupport::TestCase
  describe 'valid?' do
    test 'returns true when there are no messages' do
      result = ForemanDeployments::Validation::ValidationResult.new
      assert result.valid?
    end

    test 'returns false when there are some messages' do
      result = ForemanDeployments::Validation::ValidationResult.new([
        'Some error message'
      ])
      refute result.valid?
    end
  end

  describe 'to_s' do
    test 'is empty for valid results' do
      result = ForemanDeployments::Validation::ValidationResult.new
      assert_equal('', result.to_s)
    end

    test 'contains messages for the invalid results' do
      result = ForemanDeployments::Validation::ValidationResult.new([
        'Some error',
        'Another error'
      ])
      assert_equal("Some error\nAnother error", result.to_s)
    end

    test 'contains messages for the invalid results stored in hashes' do
      result = ForemanDeployments::Validation::ValidationResult.new(
        'e1' => 'Some error',
        'e2' => 'Another error'
      )
      assert_equal("e1: Some error\ne2: Another error", result.to_s)
    end
  end
end
