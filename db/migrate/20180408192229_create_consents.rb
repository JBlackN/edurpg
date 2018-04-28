class CreateConsents < ActiveRecord::Migration[5.1]
  def change
    create_table :consents do |t|
      t.text :page
      t.text :raw_post_data
      t.boolean :username
      t.boolean :name
      t.boolean :photo
      t.boolean :year
      t.boolean :study_plan
      t.boolean :grades
      t.boolean :titles
      t.boolean :roles
      t.boolean :classes
      t.boolean :events
      t.boolean :exams
      t.boolean :guilds
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
