class CreateCharacterCharacterAttributes < ActiveRecord::Migration[5.1]
  def change
    create_table :character_character_attributes do |t|
      t.integer :points
      t.references :character, foreign_key: true
      t.references :character_attribute, foreign_key: true

      t.timestamps
    end
  end
end
