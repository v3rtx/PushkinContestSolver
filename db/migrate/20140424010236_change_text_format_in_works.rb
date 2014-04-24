class ChangeTextFormatInWorks < ActiveRecord::Migration
  def change
  	change_column :works, :text, :text
  end
end
