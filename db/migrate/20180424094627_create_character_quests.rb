class CreateCharacterQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :character_quests do |t|
      t.references :character, foreign_key: true
      t.references :quest, foreign_key: true

      t.timestamps
    end
  end
end
