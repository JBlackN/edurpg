class AddSpecializationRefToCharacters < ActiveRecord::Migration[5.1]
  def change
    add_reference :characters, :specialization, foreign_key: true
  end
end
