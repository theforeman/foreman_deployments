class AddStack < ActiveRecord::Migration
  def change
    create_table 'stacks' do |t|
      t.string 'name', :null => false
      t.references :organization
      t.references :location
      t.belongs_to :parent
      t.timestamps
    end

    # TODO(pchalupa) add indexes
  end

end
