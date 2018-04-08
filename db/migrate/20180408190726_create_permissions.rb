class CreatePermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :permissions do |t|
      t.boolean :manage_users
      t.boolean :manage_app
      t.boolean :manage_attrs
      t.boolean :manage_achievement_categories
      t.boolean :manage_talent_trees
      t.boolean :manage_talents
      t.boolean :manage_quests
      t.boolean :manage_skills
      t.boolean :manage_achievements
      t.boolean :manage_items
      t.boolean :manage_titles
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
