class CreateStacks < ActiveRecord::Migration
  def change
    create_table :stacks do |t|
      t.string :name, :length => 254
      t.text :definition

      t.timestamps
    end
  end
end
