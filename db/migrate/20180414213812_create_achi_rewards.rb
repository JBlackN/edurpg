class CreateAchiRewards < ActiveRecord::Migration[5.1]
  def change
    create_table :achievements_items, id: false do |t|
      t.belongs_to :achievement, index: true
      t.belongs_to :item, index: true
    end

    create_table :achievements_titles, id: false do |t|
      t.belongs_to :achievement, index: true
      t.belongs_to :title, index: true
    end
  end
end
