class CreateQuestRewards < ActiveRecord::Migration[5.1]
  def change
    create_table :quests_skills, id: false do |t|
      t.belongs_to :quest, index: true
      t.belongs_to :skill, index: true
    end

    create_table :achievements_quests, id: false do |t|
      t.belongs_to :quest, index: true
      t.belongs_to :achievement, index: true
    end

    create_table :items_quests, id: false do |t|
      t.belongs_to :quest, index: true
      t.belongs_to :item, index: true
    end

    create_table :quests_titles, id: false do |t|
      t.belongs_to :quest, index: true
      t.belongs_to :title, index: true
    end
  end
end
