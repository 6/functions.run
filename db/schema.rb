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

ActiveRecord::Schema.define(version: 20161023231928) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "functions", force: :cascade do |t|
    t.text     "name",                        null: false
    t.text     "description"
    t.string   "remote_id",                   null: false
    t.string   "runtime",                     null: false
    t.text     "code",                        null: false
    t.integer  "memory_size",                 null: false
    t.integer  "timeout",                     null: false
    t.boolean  "private",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id",                     null: false
    t.boolean  "featured",    default: false
    t.index ["remote_id"], name: "index_functions_on_remote_id", unique: true, using: :btree
    t.index ["user_id", "name"], name: "index_functions_on_user_id_and_name", unique: true, using: :btree
    t.index ["user_id"], name: "index_functions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 30, null: false
    t.string   "email",                      null: false
    t.string   "password_digest",            null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "api_key",                    null: false
    t.index ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
