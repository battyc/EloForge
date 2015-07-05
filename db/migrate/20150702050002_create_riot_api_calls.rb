class CreateRiotApiCalls < ActiveRecord::Migration
  def change
    create_table :riot_api_calls do |t|
      t.text :server
      t.text :api_call, index: true
      t.text :response

      t.timestamps null: false
    end
  end
end
