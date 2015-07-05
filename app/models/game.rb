class Game < ActiveRecord::Base
	serialize :gameData
	belongs_to :summoner
end
