class AddUnlockedToTalentTreeTalents < ActiveRecord::Migration[5.1]
  def change
    add_column :talent_tree_talents, :unlocked, :boolean
  end
end
