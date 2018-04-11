class CreateCharacters < ActiveRecord::Migration[5.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.text :image
      t.integer :health
      t.integer :experience
      t.integer :level
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
