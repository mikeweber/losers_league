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

ActiveRecord::Schema[8.0].define(version: 2025_09_01_042338) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "matchups", force: :cascade do |t|
    t.bigint "week_id", null: false
    t.bigint "home_id", null: false
    t.bigint "away_id", null: false
    t.datetime "kickoff"
    t.integer "home_score"
    t.integer "away_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_id"], name: "index_matchups_on_away_id"
    t.index ["home_id"], name: "index_matchups_on_home_id"
    t.index ["week_id"], name: "index_matchups_on_week_id"
  end

  create_table "picks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "week_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_picks_on_team_id"
    t.index ["user_id"], name: "index_picks_on_user_id"
    t.index ["week_id"], name: "index_picks_on_week_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "initials"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weeks", force: :cascade do |t|
    t.bigint "season_id", null: false
    t.integer "week", null: false
    t.datetime "starts_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_weeks_on_season_id"
  end

  add_foreign_key "matchups", "teams", column: "away_id"
  add_foreign_key "matchups", "teams", column: "home_id"
  add_foreign_key "matchups", "weeks"
  add_foreign_key "picks", "teams"
  add_foreign_key "picks", "users"
  add_foreign_key "picks", "weeks"
  add_foreign_key "weeks", "seasons"
end
