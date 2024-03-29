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

ActiveRecord::Schema.define(version: 20190502022657) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "category_payments", force: :cascade do |t|
    t.integer "category_id", limit: 4, null: false
    t.integer "payment_id",  limit: 4, null: false
  end

  add_index "category_payments", ["category_id", "payment_id"], name: "index_category_payments_on_category_id_and_payment_id", unique: true, using: :btree
  add_index "category_payments", ["category_id"], name: "index_category_payments_on_category_id", using: :btree
  add_index "category_payments", ["payment_id"], name: "index_category_payments_on_payment_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.string   "payment_type", limit: 255
    t.date     "date"
    t.string   "content",      limit: 255
    t.integer  "price",        limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
