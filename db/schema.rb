# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180408192455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.binary "image"
    t.integer "health"
    t.integer "experience"
    t.integer "level"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "class_restrictions", force: :cascade do |t|
    t.string "code"
    t.bigint "permission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_class_restrictions_on_permission_id"
  end

  create_table "consents", force: :cascade do |t|
    t.text "page"
    t.text "raw_post_data"
    t.boolean "username"
    t.boolean "name"
    t.boolean "photo"
    t.boolean "year"
    t.boolean "study_plan"
    t.boolean "grades"
    t.boolean "titles"
    t.boolean "roles"
    t.boolean "classes"
    t.boolean "events"
    t.boolean "exams"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_consents_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.boolean "use_app"
    t.boolean "manage_users"
    t.boolean "manage_app"
    t.boolean "manage_attrs"
    t.boolean "manage_achievement_categories"
    t.boolean "manage_talent_trees"
    t.boolean "manage_talents"
    t.boolean "manage_quests"
    t.boolean "manage_skills"
    t.boolean "manage_achievements"
    t.boolean "manage_items"
    t.boolean "manage_titles"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "characters", "users"
  add_foreign_key "class_restrictions", "permissions"
  add_foreign_key "consents", "users"
  add_foreign_key "permissions", "users"
end
