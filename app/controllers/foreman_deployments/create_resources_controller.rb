module ForemanDeployments
  #
  class CreateResourcesController < ApplicationController
    def index
    end

    def new
      @resource = ResourceModels::CreateResource.new
      @resource.resource_type = User
      @resource.definition_hash = {
        login: 'my_user1'
      }

      @user = @resource.new_resource
    end

    def create
      params[:user].delete :admin
      description_input = {
        user1: {
          task: CreationTask,
          params: {
            klass: User,
            params: params[:user]
          }
        },
        usergroup1: {
          task: CreationTask,
          params: {
            klass: Usergroup,
            params: {
              name: 'zzz',
              user_ids: [ForemanDeployments::TaskReference.new(:user1, :object_id)]
            }
          }
        }
      }

      ForemanTasks.sync_task(StackDeployTask, description_input)

      redirect_to foreman_tasks_path
    end

    def edit
    end

    def update
    end

    def destroy
    end
  end
end
