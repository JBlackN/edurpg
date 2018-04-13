class CreateSpecializationsTalents < ActiveRecord::Migration[5.1]
  def change
    create_table :specializations_talents, id: false do |t|
      t.belongs_to :specialization, index: true
      t.belongs_to :talent, index: true
    end
  end
end
