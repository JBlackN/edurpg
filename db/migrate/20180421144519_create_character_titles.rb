class CreateCharacterTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :character_titles do |t|
      t.boolean :active
      t.references :character, foreign_key: true
      t.references :title, foreign_key: true

      t.timestamps
    end
  end
end
