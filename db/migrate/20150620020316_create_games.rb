class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :region
      t.string :matchType
      t.bigint :matchCreation
      t.text :timeline
      t.text :participants
      t.text :participantIds
      t.text :ownerParticipantId
      t.text :ownerParticipant
      t.string :platformId
      t.string :matchMode
      t.string :matchVersion
      t.text :teams
      t.string :mapId
      t.integer :matchDuration
      t.string :queueType
      t.string :season

      #t.text :gameData
      t.bigint :gameId, index: true
      t.bigint :summoner_id
      t.timestamps null: false
    end
    add_foreign_key :games, :summoners
  end
end
