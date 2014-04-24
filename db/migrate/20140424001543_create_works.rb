class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :url
      t.string :title
      t.string :text
    end
  end
end
