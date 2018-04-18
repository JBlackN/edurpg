class CreateAchievementCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :achievement_categories do |t|
      t.string :name
      t.string :code
      t.references :parent, index: true

      t.timestamps
    end
  end
end
