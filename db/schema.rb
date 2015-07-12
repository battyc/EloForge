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

ActiveRecord::Schema.define(version: 20150620020316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "region"
    t.string   "matchType"
    t.integer  "matchCreation",      limit: 8
    t.text     "timeline"
    t.text     "participants"
    t.text     "participantIds"
    t.text     "ownerParticipantId"
    t.text     "ownerParticipant"
    t.string   "platformId"
    t.string   "matchMode"
    t.string   "matchVersion"
    t.text     "teams"
    t.string   "mapId"
    t.integer  "matchDuration"
    t.string   "queueType"
    t.string   "season"
    t.integer  "gameId",             limit: 8
    t.integer  "summoner_id",        limit: 8
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "games", ["gameId"], name: "index_games_on_gameId", using: :btree

  create_table "summoners", force: :cascade do |t|
    t.string   "formattedName"
    t.string   "internalName"
    t.integer  "summonerId",    limit: 8
    t.integer  "lastUpdated",   limit: 8
    t.integer  "lastGameId",    limit: 8
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "summoners", ["internalName"], name: "index_summoners_on_internalName", using: :btree

  add_foreign_key "games", "summoners"
end
