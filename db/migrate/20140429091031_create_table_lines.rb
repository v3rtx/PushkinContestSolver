class CreateTableLines < ActiveRecord::Migration
  def change  	
    create_table :lines do |t|
      t.integer :work_id
      t.string :line_text
    end
  	add_index :lines, :work_id
  	add_index :lines, :line_text
  end

  def down
  	drop_table :lines
  	remove_index :lines, :work_id
  	remove_index :lines, :line_text
  end
end
