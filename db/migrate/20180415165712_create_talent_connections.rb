class CreateTalentConnections < ActiveRecord::Migration[5.1]
  def change
    create_table :talent_connections do |t|
      t.string :src_pos
      t.string :dest_pos
      t.string :connection_points
      t.references :src_talent
      t.references :dest_talent

      t.timestamps
    end

    add_foreign_key :talent_connections, :talent_tree_talents, column: :src_talent_id, primary_key: :id
    add_foreign_key :talent_connections, :talent_tree_talents, column: :dest_talent_id, primary_key: :id
  end
end
