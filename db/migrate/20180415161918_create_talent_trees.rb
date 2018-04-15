class CreateTalentTrees < ActiveRecord::Migration[5.1]
  def change
    create_table :talent_trees do |t|
      t.text :image
      t.integer :width
      t.integer :height
      t.integer :talent_size
      t.references :character_class, foreign_key: true
      t.references :specialization, foreign_key: true
      t.references :item, foreign_key: true

      t.timestamps
    end
  end
end
