class CreateQuestExpRewards < ActiveRecord::Migration[5.1]
  def change
    create_table :quest_exp_rewards do |t|
      t.string :points
      t.references :quest, foreign_key: true

      t.timestamps
    end
  end
end
