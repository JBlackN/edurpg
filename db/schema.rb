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

ActiveRecord::Schema.define(version: 20180510213302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_categories", force: :cascade do |t|
    t.string "name"
    t.string "code"
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

  create_table "achievements_items", id: false, force: :cascade do |t|
    t.bigint "achievement_id"
    t.bigint "item_id"
    t.index ["achievement_id"], name: "index_achievements_items_on_achievement_id"
    t.index ["item_id"], name: "index_achievements_items_on_item_id"
  end

  create_table "achievements_quests", id: false, force: :cascade do |t|
    t.bigint "quest_id"
    t.bigint "achievement_id"
    t.index ["achievement_id"], name: "index_achievements_quests_on_achievement_id"
    t.index ["quest_id"], name: "index_achievements_quests_on_quest_id"
  end

  create_table "achievements_titles", id: false, force: :cascade do |t|
    t.bigint "achievement_id"
    t.bigint "title_id"
    t.index ["achievement_id"], name: "index_achievements_titles_on_achievement_id"
    t.index ["title_id"], name: "index_achievements_titles_on_title_id"
  end

  create_table "character_achievements", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "achievement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_character_achievements_on_achievement_id"
    t.index ["character_id"], name: "index_character_achievements_on_character_id"
  end

  create_table "character_attributes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_character_attributes", force: :cascade do |t|
    t.integer "points"
    t.bigint "character_id"
    t.bigint "character_attribute_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_attribute_id"], name: "index_character_character_attributes_on_character_attribute_id"
    t.index ["character_id"], name: "index_character_character_attributes_on_character_id"
  end

  create_table "character_classes", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_items", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_items_on_character_id"
    t.index ["item_id"], name: "index_character_items_on_item_id"
  end

  create_table "character_quests", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "quest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_quests_on_character_id"
    t.index ["quest_id"], name: "index_character_quests_on_quest_id"
  end

  create_table "character_skills", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_skills_on_character_id"
    t.index ["skill_id"], name: "index_character_skills_on_skill_id"
  end

  create_table "character_titles", force: :cascade do |t|
    t.boolean "active"
    t.bigint "character_id"
    t.bigint "title_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_titles_on_character_id"
    t.index ["title_id"], name: "index_character_titles_on_title_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.text "image"
    t.integer "experience"
    t.integer "level"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "character_class_id"
    t.bigint "specialization_id"
    t.index ["character_class_id"], name: "index_characters_on_character_class_id"
    t.index ["specialization_id"], name: "index_characters_on_specialization_id"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "class_restrictions", force: :cascade do |t|
    t.string "code"
    t.string "code_full"
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
    t.boolean "grades"
    t.boolean "info"
    t.boolean "roles"
    t.boolean "classes"
    t.boolean "guilds"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_consents_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
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
    t.bigint "character_class_id"
    t.bigint "specialization_id"
    t.index ["character_class_id"], name: "index_items_on_character_class_id"
    t.index ["specialization_id"], name: "index_items_on_specialization_id"
  end

  create_table "items_quests", id: false, force: :cascade do |t|
    t.bigint "quest_id"
    t.bigint "item_id"
    t.index ["item_id"], name: "index_items_quests_on_item_id"
    t.index ["quest_id"], name: "index_items_quests_on_quest_id"
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

  create_table "quests", force: :cascade do |t|
    t.string "name"
    t.string "difficulty"
    t.string "objectives"
    t.string "description"
    t.datetime "deadline"
    t.string "completion_check_id"
    t.bigint "character_id"
    t.bigint "character_class_id"
    t.bigint "specialization_id"
    t.bigint "talent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_class_id"], name: "index_quests_on_character_class_id"
    t.index ["character_id"], name: "index_quests_on_character_id"
    t.index ["specialization_id"], name: "index_quests_on_specialization_id"
    t.index ["talent_id"], name: "index_quests_on_talent_id"
  end

  create_table "quests_skills", id: false, force: :cascade do |t|
    t.bigint "quest_id"
    t.bigint "skill_id"
    t.index ["quest_id"], name: "index_quests_skills_on_quest_id"
    t.index ["skill_id"], name: "index_quests_skills_on_skill_id"
  end

  create_table "quests_titles", id: false, force: :cascade do |t|
    t.bigint "quest_id"
    t.bigint "title_id"
    t.index ["quest_id"], name: "index_quests_titles_on_quest_id"
    t.index ["title_id"], name: "index_quests_titles_on_title_id"
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
    t.string "abbr"
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

  create_table "talent_attributes", force: :cascade do |t|
    t.integer "points"
    t.bigint "talent_id"
    t.bigint "character_attribute_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_attribute_id"], name: "index_talent_attributes_on_character_attribute_id"
    t.index ["talent_id"], name: "index_talent_attributes_on_talent_id"
  end

  create_table "talent_connections", force: :cascade do |t|
    t.string "src_pos"
    t.string "dest_pos"
    t.string "connection_points"
    t.bigint "src_talent_id"
    t.bigint "dest_talent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dest_talent_id"], name: "index_talent_connections_on_dest_talent_id"
    t.index ["src_talent_id"], name: "index_talent_connections_on_src_talent_id"
  end

  create_table "talent_tree_talents", force: :cascade do |t|
    t.integer "pos_x"
    t.integer "pos_y"
    t.bigint "talent_tree_id"
    t.bigint "talent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "unlocked"
    t.index ["talent_id"], name: "index_talent_tree_talents_on_talent_id"
    t.index ["talent_tree_id"], name: "index_talent_tree_talents_on_talent_tree_id"
  end

  create_table "talent_trees", force: :cascade do |t|
    t.text "image"
    t.integer "width"
    t.integer "height"
    t.integer "talent_size"
    t.bigint "character_class_id"
    t.bigint "specialization_id"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "character_id"
    t.index ["character_class_id"], name: "index_talent_trees_on_character_class_id"
    t.index ["character_id"], name: "index_talent_trees_on_character_id"
    t.index ["item_id"], name: "index_talent_trees_on_item_id"
    t.index ["specialization_id"], name: "index_talent_trees_on_specialization_id"
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

  create_table "titles", force: :cascade do |t|
    t.string "title"
    t.boolean "after_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret_key"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "achievements", "achievement_categories"
  add_foreign_key "character_achievements", "achievements"
  add_foreign_key "character_achievements", "characters"
  add_foreign_key "character_character_attributes", "character_attributes"
  add_foreign_key "character_character_attributes", "characters"
  add_foreign_key "character_items", "characters"
  add_foreign_key "character_items", "items"
  add_foreign_key "character_quests", "characters"
  add_foreign_key "character_quests", "quests"
  add_foreign_key "character_skills", "characters"
  add_foreign_key "character_skills", "skills"
  add_foreign_key "character_titles", "characters"
  add_foreign_key "character_titles", "titles"
  add_foreign_key "characters", "character_classes"
  add_foreign_key "characters", "specializations"
  add_foreign_key "characters", "users"
  add_foreign_key "class_restrictions", "permissions"
  add_foreign_key "consents", "users"
  add_foreign_key "item_attributes", "character_attributes"
  add_foreign_key "item_attributes", "items"
  add_foreign_key "items", "character_classes"
  add_foreign_key "items", "specializations"
  add_foreign_key "permissions", "users"
  add_foreign_key "quests", "character_classes"
  add_foreign_key "quests", "characters"
  add_foreign_key "quests", "specializations"
  add_foreign_key "quests", "talents"
  add_foreign_key "skills", "character_attributes"
  add_foreign_key "specializations", "character_classes"
  add_foreign_key "talent_attributes", "character_attributes"
  add_foreign_key "talent_attributes", "talents"
  add_foreign_key "talent_connections", "talent_tree_talents", column: "dest_talent_id"
  add_foreign_key "talent_connections", "talent_tree_talents", column: "src_talent_id"
  add_foreign_key "talent_tree_talents", "talent_trees"
  add_foreign_key "talent_tree_talents", "talents"
  add_foreign_key "talent_trees", "character_classes"
  add_foreign_key "talent_trees", "characters"
  add_foreign_key "talent_trees", "items"
  add_foreign_key "talent_trees", "specializations"
end
