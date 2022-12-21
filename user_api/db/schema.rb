# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_21_120120) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forum_comments", force: :cascade do |t|
    t.text "comment", null: false
    t.integer "forum_post", null: false
    t.string "comment_owner", null: false
    t.integer "top_comment"
    t.integer "level"
    t.integer "parent"
    t.json "children", default: [], array: true
    t.json "votes", default: {"up"=>0, "down"=>0}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forums", force: :cascade do |t|
    t.string "topic", null: false
    t.string "creator", null: false
    t.text "content"
    t.string "anime"
    t.json "votes", default: {"up"=>0, "down"=>0}
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_comments", force: :cascade do |t|
    t.text "comment", null: false
    t.integer "review_id", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "top_comment"
    t.string "comment_type", null: false
    t.integer "parent", null: false
    t.integer "likes", default: 0
  end

  create_table "reviews", force: :cascade do |t|
    t.string "user", null: false
    t.string "show", null: false
    t.integer "rating", null: false
    t.string "amount_watched"
    t.text "highlighted_points", default: [], array: true
    t.text "overall_review"
    t.string "referral_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "watch_priority"
    t.integer "likes", default: 0
  end

  create_table "rooms", force: :cascade do |t|
    t.string "room_name", null: false
    t.json "users", default: {}
    t.boolean "private", default: true
    t.json "pending_approval", default: {}
    t.json "admin", default: {"group_admin"=>true, "admin_users"=>{}}
    t.json "entry_keys", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_name"], name: "index_rooms_on_room_name"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "genre_preference"
    t.string "go_to_motto"
    t.text "user_grade_protocol"
    t.json "rooms", default: {}
    t.json "peers", default: {}
    t.json "requests", default: {"room"=>{}, "peer"=>{}, "roomAuth"=>{}}
    t.string "session_token"
    t.index ["username"], name: "index_users_on_username"
  end

end
