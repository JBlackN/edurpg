class CreateAchievements < ActiveRecord::Migration[5.1]
  def change
    create_table :achievements do |t|
      t.string :name
      t.text :image
      t.string :description
      t.integer :points
      t.references :achievement_category, foreign_key: true

      t.timestamps
    end
  end
end
