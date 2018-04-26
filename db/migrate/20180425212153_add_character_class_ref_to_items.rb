class AddCharacterClassRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :character_class, foreign_key: true
  end
end
