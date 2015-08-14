class CreateDeployment < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :description, :length => 254
      t.text :values
      t.references :stack, :null => false

      t.timestamps
    end
    add_foreign_key :configurations, :stacks, :name => :configurations_stack_id_fk

    create_table :deployments do |t|
      t.string :name, :length => 254
      t.references :configuration, :null => false

      t.timestamps
    end
    add_foreign_key :deployments, :configurations, :name => :deployemnts_configuration_id_fk
  end
end
