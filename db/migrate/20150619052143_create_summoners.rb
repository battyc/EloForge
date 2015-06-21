class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.string :formattedName
      t.string :internalName
      t.integer :summonerId
      t.time :lastUpdated
      t.integer :lastGameId

      t.timestamps null: false
    end
    add_index :summoners, :internalName
  end
end
