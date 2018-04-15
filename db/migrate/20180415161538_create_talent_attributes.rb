class CreateTalentAttributes < ActiveRecord::Migration[5.1]
  def change
    create_table :talent_attributes do |t|
      t.integer :points
      t.references :talent, foreign_key: true
      t.references :character_attribute, foreign_key: true

      t.timestamps
    end
  end
end
