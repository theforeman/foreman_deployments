class AddTaskToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :task_id, :string
  end
end
