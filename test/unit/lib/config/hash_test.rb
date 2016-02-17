require 'test_helper'

class HashTest < ActiveSupport::TestCase
  describe 'merge_configuration' do
    test 'can set values' do
      hash = ForemanDeployments::Config::Hash[]
      hash.merge_configuration(:b => 3)
      assert_equal({ 'b' => 3 }, hash.configured)
    end

    test 'calls configure on configurable items' do
      configurable = mock
      configurable.expects(:merge_configuration).with(123).once

      hash = ForemanDeployments::Config::Hash[:a => configurable]
      hash.merge_configuration(:a => 123)
    end

    test 'can delete value with setting nil' do
      hash = ForemanDeployments::Config::Hash[]
      hash.merge_configuration(:b => 2)
      hash.merge_configuration(:b => nil)
      assert_equal({}, hash.configured)
    end

    test 'keeps preconfigured values untouched' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      hash.merge_configuration(:b => 2)
      assert_equal({ 'a' => 1 }, hash)
    end

    test 'can add additional preconfigured hashses' do
      hash = ForemanDeployments::Config::Hash[]
      hash.merge_configuration(:a => { :b => 1 })

      assert_equal({}, hash['a'])
      assert_equal(ForemanDeployments::Config::Hash, hash['a'].class)
    end

    test 'can add additional preconfigured arrays' do
      hash = ForemanDeployments::Config::Hash[]
      hash.merge_configuration(:a => [:b, :c])

      assert_equal([nil, nil], hash['a'])
      assert_equal(ForemanDeployments::Config::Array, hash['a'].class)
    end

    test 'raises exception when a value would be overwritten' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        hash.merge_configuration(:a => 2)
      end
      assert_match("You can't override values hardcoded in the stack definition", e.message)
      assert_equal({ 'a' => 1 }, hash.configured)
    end
  end

  describe 'configure' do
    test 'can set values' do
      hash = ForemanDeployments::Config::Hash[]
      hash.configure(:b => 3)
      assert_equal({ 'b' => 3 }, hash.configured)
    end

    test 'calls configure on configurable items' do
      configurable = mock
      configurable.expects(:configure).with(123).once

      hash = ForemanDeployments::Config::Hash[:a => configurable]
      hash.configure(:a => 123)
    end

    test 'it overwrites previous config' do
      hash = ForemanDeployments::Config::Hash[]
      hash.configure(:b => 2)
      hash.configure(:a => 1)
      assert_equal({ 'a' => 1 }, hash.configured)
    end

    test 'keeps preconfigured values untouched' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      hash.configure(:b => 2)
      assert_equal({ 'a' => 1 }, hash)
    end

    test 'can add additional preconfigured hashses' do
      hash = ForemanDeployments::Config::Hash[]
      hash.configure(:a => { :b => 1 })

      assert_equal({}, hash['a'])
      assert_equal(ForemanDeployments::Config::Hash, hash['a'].class)
    end

    test 'can add additional preconfigured arrays' do
      hash = ForemanDeployments::Config::Hash[]
      hash.configure(:a => [:b, :c])

      assert_equal([nil, nil], hash['a'])
      assert_equal(ForemanDeployments::Config::Array, hash['a'].class)
    end

    test 'raises exception when a value would be overwritten' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      e = assert_raises ForemanDeployments::Config::InvalidValueException do
        hash.configure(:a => 2)
      end
      assert_match("You can't override values hardcoded in the stack definition", e.message)
      assert_equal({ 'a' => 1 }, hash.configured)
    end
  end

  describe 'configuration' do
    test 'returns nil by default' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      assert_nil(hash.configuration)
    end

    test 'returns nil when the config was erased' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      hash.configure(:b => 2)
      hash.configure(:b => nil)
      assert_nil(hash.configuration)
    end

    test 'returns only configured values' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      hash.configure(:b => 2, :c => 3)
      assert_equal({ 'b' => 2, 'c' => 3 }, hash.configuration)
    end

    test 'returns configured values from inner items' do
      configurable = mock
      configurable.stubs(:configuration).returns(123)

      hash = ForemanDeployments::Config::Hash[:a => configurable]
      hash.configure(:b => 2)
      assert_equal({ 'a' => 123, 'b' => 2 }, hash.configuration)
    end
  end

  describe 'configured' do
    test 'returns preconfigured values mixed with the configuration' do
      hash = ForemanDeployments::Config::Hash[:a => 1]
      hash.configure(:b => 2)
      assert_equal({ 'a' => 1, 'b' => 2 }, hash.configured)
    end

    test 'returns values from inner items' do
      configurable = mock
      configurable.stubs(:configured).returns('c' => 123)

      hash = ForemanDeployments::Config::Hash[:a => configurable]
      hash.configure(:b => 2)
      assert_equal({ 'a' => { 'c' => 123 }, 'b' => 2 }, hash.configured)
    end
  end

  describe 'transform!' do
    test 'transforms values' do
      hash = ForemanDeployments::Config::Hash['a' => 1, 'b' => 2]
      hash.transform! { |key, val| [key, val * 2] }
      assert_equal({ 'a' => 2, 'b' => 4 }, hash)
    end

    test 'enables to change the keys' do
      hash = ForemanDeployments::Config::Hash['a' => 1, 'b' => 2]
      hash.transform! { |key, val| [key * 2, val * 2] }
      assert_equal({ 'aa' => 2, 'bb' => 4 }, hash)
    end

    test 'keeps the configuration' do
      hash = ForemanDeployments::Config::Hash['a' => 1, 'b' => 2]
      hash.configure('c' => 3)
      hash.transform! { |key, val| [key, val * 2] }
      assert_equal({ 'c' => 3 }, hash.configuration)
    end
  end
end
