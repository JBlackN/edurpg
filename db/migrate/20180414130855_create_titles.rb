class CreateTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :titles do |t|
      t.string :title
      t.boolean :after_name

      t.timestamps
    end
  end
end
