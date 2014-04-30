# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140429091031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lines", force: true do |t|
    t.integer "work_id"
    t.string  "line_text"
  end

  add_index "lines", ["line_text"], name: "index_lines_on_line_text", using: :btree
  add_index "lines", ["work_id"], name: "index_lines_on_work_id", using: :btree

  create_table "logs", force: true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "works", force: true do |t|
    t.string "url"
    t.string "title"
    t.text   "text"
  end

  add_index "works", ["text"], name: "index_works_on_text", using: :btree

  create_table "works_tables", force: true do |t|
    t.string "url"
    t.string "title"
    t.string "text"
  end

end
