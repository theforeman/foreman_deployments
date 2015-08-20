require 'test_helper'

class TaskReferenceTest < ActiveSupport::TestCase
  test 'referenced task can be optionally set in the constructor' do
    task = mock
    ref = ForemanDeployments::TaskReference.new('task', 'resource.id', task)
    assert_equal(task, ref.task)
  end

  describe 'dereference' do
    test 'it dereferences hash' do
      ref = ForemanDeployments::TaskReference.new('task', 'resource.id')
      value = ref.dereference('resource' => { 'id' => 123 })
      assert_equal(123, value)
    end

    test 'it dereferences object' do
      obj = mock
      obj.stubs(:id).returns(123)

      ref = ForemanDeployments::TaskReference.new('task', 'resource.id')
      value = ref.dereference('resource' => obj)
      assert_equal(123, value)
    end

    test 'it return nil when the key does not exist' do
      ref = ForemanDeployments::TaskReference.new('task', 'resource.unknown')
      value = ref.dereference('resource' => {})
      assert_equal(nil, value)
    end

    test 'it return nil when the method does not exist' do
      ref = ForemanDeployments::TaskReference.new('task', 'resource.unknown')
      value = ref.dereference('resource' => Object.new)
      assert_equal(nil, value)
    end

    test 'it dereferences one item path' do
      obj = mock

      ref = ForemanDeployments::TaskReference.new('task', 'resource')
      value = ref.dereference('resource' => obj)
      assert_equal(obj, value)
    end

    test 'it dereferences one item path defined by symbol' do
      obj = mock

      ref = ForemanDeployments::TaskReference.new('task', :resource)
      value = ref.dereference('resource' => obj)
      assert_equal(obj, value)
    end
  end

  test 'accept calls visit on the visitor with self' do
    ref = ForemanDeployments::TaskReference.new('task', 'resource.id')

    visitor = mock
    visitor.expects(:visit).with(ref).once

    ref.accept(visitor)
  end
end
