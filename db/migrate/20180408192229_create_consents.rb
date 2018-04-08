class CreateConsents < ActiveRecord::Migration[5.1]
  def change
    create_table :consents do |t|
      t.binary :page
      t.boolean :username
      t.boolean :name
      t.datetime :photo
      t.boolean :year
      t.boolean :study_plan
      t.boolean :grades
      t.boolean :title
      t.boolean :roles
      t.boolean :classes
      t.boolean :events
      t.boolean :exams
      t.datetime :expires
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
