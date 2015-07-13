class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.string :formattedName
      t.string :internalName
      t.bigint :summonerId
      t.bigint :lastUpdated
      t.bigint :lastGameId
      t.string :server

      t.timestamps null: false
    end
    add_index :summoners, :internalName
  end
end
