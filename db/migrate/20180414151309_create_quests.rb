class CreateQuests < ActiveRecord::Migration[5.1]
  def change
    create_table :quests do |t|
      t.string :name
      t.string :difficulty
      t.string :objectives
      t.string :description
      t.datetime :deadline
      t.string :completion_check_id
      t.references :character, foreign_key: true
      t.references :character_class, foreign_key: true
      t.references :specialization, foreign_key: true
      t.references :talent, foreign_key: true

      t.timestamps
    end
  end
end
