class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :image
      t.string :description
      t.string :rarity

      t.timestamps
    end
  end
end
