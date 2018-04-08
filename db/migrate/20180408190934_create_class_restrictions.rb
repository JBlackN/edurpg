class CreateClassRestrictions < ActiveRecord::Migration[5.1]
  def change
    create_table :class_restrictions do |t|
      t.string :code
      t.references :permission, foreign_key: true

      t.timestamps
    end
  end
end
