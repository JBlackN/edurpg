class CreateItemAttributes < ActiveRecord::Migration[5.1]
  def change
    create_table :item_attributes do |t|
      t.integer :points
      t.references :item, foreign_key: true
      t.references :character_attribute, foreign_key: true

      t.timestamps
    end
  end
end
