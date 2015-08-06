require 'test_plugin_helper'

# rubocop:disable Metrics/ClassLength
class TaskDefinitionTest < ActiveSupport::TestCase
  setup do
    @parent_task = stub('parent_task')
  end

  context 'Single task validation' do
    setup do
      @params = {
        str_prop: 'hello world',
        int_prop: 5,
        arr_prop: ['abc', 5],
        hash_prop: {
          inner1: 'inner1val',
          inner2: 'inner2val'
        }
      }
    end

    test 'doesnt touch col1_id columns that are not references' do
      @params[:related_id] = 'something'

      definition = ForemanDeployments::TaskDefinition.new({},
                                                          TestUserTask,
                                                          @params)

      validation_result = ForemanDeployments::ValidationResult.new({}) do
        true
      end

      TestUserTask.expects(:get_validation_object).with do |actual_params|
        assert_equal 'something', actual_params[:related_id]
        assert_equal @params, actual_params
      end.returns(validation_result)

      definition.validate
    end

    test 'validates task output type' do
      definition = ForemanDeployments::TaskDefinition.new({},
                                                          TestUserTask,
                                                          @params)

      TestUserTask.expects(:get_validation_object)
        .returns('not validation result')

      assert_raise ArgumentError do
        definition.validate
      end
    end

    test 'runs validation as defined by the task' do
      definition = ForemanDeployments::TaskDefinition.new({},
                                                          TestUserTask,
                                                          @params)

      validation_result = ForemanDeployments::ValidationResult.new({}) do
        true
      end

      TestUserTask.expects(:get_validation_object).returns(validation_result)
      validation_result.expects(:validate!)

      definition.validate
    end
  end

  context 'Related tasks validation' do
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

      @definitions = {}
      @description.each_pair do |k, v|
        @definitions[k] = ForemanDeployments::TaskDefinition.new(
          @definitions,
          v[:task],
          v[:params])
      end
    end

    test 'changes col1_id columns to col1 for validation' do
      definition = @definitions[:usergroup1_single_ref]

      return_true = proc { true }
      user_validation_hash = { object_id: mock('user') }
      user_validation_result = ForemanDeployments::ValidationResult.new(
        user_validation_hash,
        &return_true)

      usergroup_validation_hash = { object_id: mock('group') }
      usergroup_validation_result = ForemanDeployments::ValidationResult.new(
        usergroup_validation_hash,
        &return_true)

      TestUserTask.expects(:get_validation_object)
        .returns(user_validation_result)
      TestUsergroupTask.expects(:get_validation_object).with do |actual_params|
        params = actual_params[:params]
        refute_nil params[:user] || params['user']
        true
      end.returns(usergroup_validation_result)

      definition.validate
    end

    test 'changes item_ids columns to items for validation' do
      definition = @definitions[:usergroup2_arr_ref]

      return_true = proc { true }
      user_validation_hash = { object_id: mock('user') }
      user_validation_result = ForemanDeployments::ValidationResult.new(
        user_validation_hash,
        &return_true)

      usergroup_validation_hash = { object_id: mock('group') }
      usergroup_validation_result = ForemanDeployments::ValidationResult.new(
        usergroup_validation_hash,
        &return_true)

      TestUserTask.expects(:get_validation_object)
        .returns(user_validation_result)
      TestUsergroupTask.expects(:get_validation_object).with do |actual_params|
        params = actual_params[:params]
        refute_nil params[:users].try(:first) || params['users'].try(:first)
        true
      end.returns(usergroup_validation_result)

      definition.validate
    end
  end

  test 'All tasks are planned' do
    @description = {
      user1: {
        task: TestUserTask,
        params: {
          klass: User,
          params: {
            str_prop: 'user1'
          }
        }
      },
      user2: {
        task: TestUserTask,
        params: {
          klass: User,
          params: {
            str_prop: 'user2'
          }
        }
      },
      user3: {
        task: TestUserTask,
        params: {
          klass: User,
          params: {
            str_prop: 'user3'
          }
        }
      },
      usergroup1: {
        task: TestUsergroupTask,
        params: {
          klass: Usergroup,
          params: {
            name: 'group1',
            user_id: ForemanDeployments::TaskReference.new(:user1, :object_id)
          }
        }
      },
      usergroup2: {
        task: TestUsergroupTask,
        params: {
          klass: Usergroup,
          params: {
            name: 'group2',
            user_ids: [
              ForemanDeployments::TaskReference.new(:user2, :object_id),
              ForemanDeployments::TaskReference.new(:usergroup1, :object_id)
            ]
          }
        }
      }
    }

    @definitions = {}
    @description.each_pair do |k, v|
      @definitions[k] = ForemanDeployments::TaskDefinition.new(
        @definitions,
        v[:task],
        v[:params])
    end

    @parent_task.expects(:send).with do |action_sym|
      action_sym == :plan_action
    end.times(5)
      .returns(OpenStruct.new(output: { object_id: mock('myObj') }))

    @definitions.values.each { |d| d.plan(@parent_task) }
  end
end
