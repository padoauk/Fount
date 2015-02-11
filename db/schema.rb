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

ActiveRecord::Schema.define(version: 20140101212236) do

  create_table "cells", force: true do |t|
    t.string   "name"
    t.string   "cell_type"
    t.string   "size"
    t.integer  "bit_pos"
    t.string   "val"
    t.integer  "packet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seq"
    t.string   "byte_pos"
  end

  add_index "cells", ["packet_id"], name: "index_cells_on_packet_id"

  create_table "packets", force: true do |t|
    t.string   "name_space"
    t.string   "name"
    t.string   "version"
    t.boolean  "is_active"
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
