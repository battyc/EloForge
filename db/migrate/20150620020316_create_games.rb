class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text :gameData
      t.bigint :gameId, index: true
      t.bigint :summoner_id
      t.timestamps null: false
    end
    add_foreign_key :games, :summoners
  end
end
