class CreateSpecializations < ActiveRecord::Migration[5.1]
  def change
    create_table :specializations do |t|
      t.string :name
      t.string :code
      t.references :character_class, foreign_key: true

      t.timestamps
    end
  end
end
