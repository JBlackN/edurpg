class CreateCharacterAttributes < ActiveRecord::Migration[5.1]
  def change
    create_table :character_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end
