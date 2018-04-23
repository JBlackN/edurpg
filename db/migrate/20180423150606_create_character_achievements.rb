class CreateCharacterAchievements < ActiveRecord::Migration[5.1]
  def change
    create_table :character_achievements do |t|
      t.references :character, foreign_key: true
      t.references :achievement, foreign_key: true

      t.timestamps
    end
  end
end
