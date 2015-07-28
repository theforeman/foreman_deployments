require 'dynflow/testing'
require 'test_plugin_helper'

#
class StackDeployTaskTest < ActiveSupport::TestCase
  include ::Dynflow::Testing

  setup do
    @description = {
      user1: {
        task: TestUserTask,
        params: {
          klass: User,
          params: {
            str_prop: 'hello world',
            int_prop: 5,
            arr_prop: ['abc', 5],
            hash_prop: {
              inner1: 'inner1val',
              inner2: 'inner2val'
            }
          }
        }
      },
      usergroup1_single_ref: {
        task: TestUsergroupTask,
        params: {
          klass: Usergroup,
          params: {
            name: 'zzz',
            user_id: ForemanDeployments::TaskReference.new(:user1, :object_id)
          }
        }
      },
      usergroup2_arr_ref: {
        task: TestUsergroupTask,
        params: {
          klass: Usergroup,
          params: {
            name: 'zzz',
            user_ids: [ForemanDeployments::TaskReference.new(:user1,
                                                             :object_id)]
          }
        }
      }
    }
  end

  it 'validates and plans all descriptions' do
    task = create_and_plan_action(ForemanDeployments::StackDeployTask,
                                  @description)

    ForemanDeployments::TaskDefinition.any_instance.expects(:validate).times(3)
    ForemanDeployments::TaskDefinition.any_instance.expects(:plan).times(3)

    task.plan(@description)
  end

  it 'throws an exception when one of the inner tasks fails validation' do
    task = create_and_plan_action(ForemanDeployments::StackDeployTask,
                                  @description)

    ForemanDeployments::TaskDefinition.any_instance.expects(:validate).times(3)
      .returns(nil, nil)
      .then.throws(:validation_errors)

    assert_raise ArgumentError do
      task.plan(@description)
    end
  end
end
