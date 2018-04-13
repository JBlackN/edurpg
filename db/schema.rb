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

ActiveRecord::Schema.define(version: 20180413201020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_categories", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_achievement_categories_on_parent_id"
  end

  create_table "achievements", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.string "description"
    t.integer "points"
    t.bigint "achievement_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_category_id"], name: "index_achievements_on_achievement_category_id"
  end

  create_table "character_attributes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_classes", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.text "image"
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

  create_table "item_attributes", force: :cascade do |t|
    t.integer "points"
    t.bigint "item_id"
    t.bigint "character_attribute_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_attribute_id"], name: "index_item_attributes_on_character_attribute_id"
    t.index ["item_id"], name: "index_item_attributes_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.string "description"
    t.string "rarity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.string "description"
    t.integer "rank"
    t.bigint "character_attribute_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_attribute_id"], name: "index_skills_on_character_attribute_id"
  end

  create_table "specializations", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "character_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_class_id"], name: "index_specializations_on_character_class_id"
  end

  create_table "specializations_talents", id: false, force: :cascade do |t|
    t.bigint "specialization_id"
    t.bigint "talent_id"
    t.index ["specialization_id"], name: "index_specializations_talents_on_specialization_id"
    t.index ["talent_id"], name: "index_specializations_talents_on_talent_id"
  end

  create_table "talents", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.text "description"
    t.integer "points"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "achievements", "achievement_categories"
  add_foreign_key "characters", "users"
  add_foreign_key "class_restrictions", "permissions"
  add_foreign_key "consents", "users"
  add_foreign_key "item_attributes", "character_attributes"
  add_foreign_key "item_attributes", "items"
  add_foreign_key "permissions", "users"
  add_foreign_key "skills", "character_attributes"
  add_foreign_key "specializations", "character_classes"
end
