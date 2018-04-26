class AddSpecializationRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :specialization, foreign_key: true
  end
end
