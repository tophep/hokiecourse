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

ActiveRecord::Schema.define(version: 20140107220253) do

  create_table "additional_times", force: true do |t|
    t.string   "begin"
    t.string   "end"
    t.string   "location"
    t.string   "days"
    t.integer  "course_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_times", ["course_id"], name: "course_id_ix"

  create_table "courses", force: true do |t|
    t.string   "crn"
    t.string   "title"
    t.integer  "cred_hours"
    t.string   "instructor"
    t.string   "begin"
    t.string   "end"
    t.string   "location"
    t.integer  "subject_id"
    t.boolean  "online"
    t.string   "days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject_code"
    t.string   "year"
    t.string   "term"
    t.boolean  "open"
  end

  create_table "subjects", force: true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
