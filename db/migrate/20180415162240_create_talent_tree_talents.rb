class CreateTalentTreeTalents < ActiveRecord::Migration[5.1]
  def change
    create_table :talent_tree_talents do |t|
      t.integer :pos_x
      t.integer :pos_y
      t.references :talent_tree, foreign_key: true
      t.references :talent, foreign_key: true

      t.timestamps
    end
  end
end
