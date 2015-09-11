require 'test_helper'

class ArrayTest < ActiveSupport::TestCase
  describe 'merge_configuration' do
    setup do
      @array = ForemanDeployments::Config::Array[nil, nil]
    end

    test 'can set values to empty slots' do
      @array.merge_configuration([1, 2])
      assert_equal([1, 2], @array.configured)
    end

    test 'can be configured with shorter array' do
      @array.merge_configuration([1])
      assert_equal([1, nil], @array.configured)
    end

    test 'can be configured with hash' do
      @array.merge_configuration(1 => :b)
      assert_equal([nil, :b], @array.configured)
    end

    test 'can be configured with hash using string keys' do
      @array.merge_configuration('1' => :b)
      assert_equal([nil, :b], @array.configured)
    end

    test 'raises exception when configured with hash using non-numeric string keys' do
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        @array.merge_configuration('abc' => :b)
      end
      assert_match("Key 'abc' isn't numeric value", e.message)
      assert_equal([nil, nil], @array.configured)
    end

    test 'can delete value with setting nil' do
      @array.configure([1, 2])
      @array.merge_configuration(1 => nil)
      assert_equal([1, nil], @array.configured)
    end

    test 'calls configure on configurable items' do
      configurable = mock
      configurable.expects(:merge_configuration).with(123).once
      array = ForemanDeployments::Config::Array[configurable]
      array.merge_configuration([123])
    end

    test 'keeps preconfigured values untouched' do
      @array.configure([1, 2])
      assert_equal([nil, nil], @array)
    end

    test 'raises exception when extra value is added' do
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        @array.merge_configuration([1, 2, 3])
      end
      assert_match("Can't configure items outside the range", e.message)
      assert_equal([nil, nil], @array.configured)
    end

    test 'raises exception when a value would be overwritten' do
      array = ForemanDeployments::Config::Array[nil, 1]
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        array.merge_configuration([1, 2])
      end
      assert_match("You can't override values hardcoded in the stack definition", e.message)
      assert_equal([1, 1], array.configured)
    end
  end

  describe 'configure' do
    setup do
      @array = ForemanDeployments::Config::Array[nil, nil]
    end

    test 'can set values to empty slots' do
      @array.configure([1, 2])
      assert_equal([1, 2], @array.configured)
    end

    test 'overrides the config when called twice' do
      @array.configure([1, 2])
      @array.configure([3])
      assert_equal([3, nil], @array.configured)
    end

    test 'can be configured with shorter array' do
      @array.configure([1])
      assert_equal([1, nil], @array.configured)
    end

    test 'can be configured with hash' do
      @array.configure(1 => :b)
      assert_equal([nil, :b], @array.configured)
    end

    test 'can be configured with hash using string keys' do
      @array.configure('1' => :b)
      assert_equal([nil, :b], @array.configured)
    end

    test 'raises exception when configured with hash using non-numeric string keys' do
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        @array.configure('abc' => :b)
      end
      assert_match("Key 'abc' isn't numeric value", e.message)
      assert_equal([nil, nil], @array.configured)
    end

    test 'calls configure on configurable items' do
      configurable = mock
      configurable.expects(:configure).with(123).once
      array = ForemanDeployments::Config::Array[configurable]
      array.configure([123])
    end

    test 'keeps preconfigured values untouched' do
      @array.configure([1, 2])
      assert_equal([nil, nil], @array)
    end

    test 'raises exception when extra value is added' do
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        @array.configure([1, 2, 3])
      end
      assert_match("Can't configure items outside the range", e.message)
      assert_equal([nil, nil], @array.configured)
    end

    test 'raises exception when a value would be overwritten' do
      array = ForemanDeployments::Config::Array[nil, 1]
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        array.configure([1, 2])
      end
      assert_match("You can't override values hardcoded in the stack definition", e.message)
      assert_equal([1, 1], array.configured)
    end
  end

  describe 'configuration' do
    test 'returns nil by default' do
      array = ForemanDeployments::Config::Array[:a, nil]
      assert_nil(array.configuration)
    end

    test 'returns nil when the config was erased' do
      array = ForemanDeployments::Config::Array[:a, nil]
      array.configure(1 => 2)
      array.configure(1 => nil)
      assert_nil(array.configuration)
    end

    test 'returns only configured values' do
      array = ForemanDeployments::Config::Array[nil, :b]
      array.configure([:a])
      assert_equal({ 0 => :a }, array.configuration)
    end

    test 'returns configured values from inner items' do
      configurable = mock
      configurable.stubs(:configuration).returns(123)

      array = ForemanDeployments::Config::Array[nil, configurable]
      assert_equal({ 1 => 123 }, array.configuration)
    end
  end

  describe 'configured' do
    test 'returns preconfigured values mixed with the configuration' do
      array = ForemanDeployments::Config::Array[:a, nil]
      array.configure(1 => :b)
      assert_equal([:a, :b], array.configured)
    end

    test 'returns values from inner items' do
      configurable = mock
      configurable.stubs(:configured).returns(123)

      array = ForemanDeployments::Config::Array[:a, configurable]
      assert_equal([:a, 123], array.configured)
    end
  end

  describe 'transform!' do
    setup do
      @array = ForemanDeployments::Config::Array[1, 2, nil]
      @array.configure(2 => :value)
      @array.transform!(&:to_s)
    end

    test 'transforms values' do
      assert_equal(['1', '2', ''], @array)
    end

    test 'keeps the configuration' do
      assert_equal({ 2 => :value }, @array.configuration)
    end
  end
end
