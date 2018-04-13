class CreateTalents < ActiveRecord::Migration[5.1]
  def change
    create_table :talents do |t|
      t.string :name
      t.text :image
      t.text :description
      t.integer :points
      t.string :code

      t.timestamps
    end
  end
end
