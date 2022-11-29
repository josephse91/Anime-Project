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

ActiveRecord::Schema[7.0].define(version: 2022_11_29_173824) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "review_comments", force: :cascade do |t|
    t.string "comment", null: false
    t.integer "review_id"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.string "user", null: false
    t.string "show", null: false
    t.integer "rating", null: false
    t.string "amount_watched"
    t.string "highlighted_points"
    t.string "overall_review"
    t.string "referral_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "genre_preference"
    t.string "go_to_motto"
    t.string "user_grade_protocol"
    t.text "rooms", default: [], array: true
    t.text "peers", default: [], array: true
    t.json "requests"
    t.index ["username"], name: "index_users_on_username"
  end

end
