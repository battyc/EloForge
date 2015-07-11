class Game < ActiveRecord::Base
	serialize :gameData
	belongs_to :summoner

	def self.updateLastRanked(gameHash)
    	# Check if name is already connected to a number.
    	summId = gameHash[:summId].to_s
    	server = gameHash[:server].to_s
    	#gameHash[:gameId]
		#Get Match History
		call = RiotApiCall.new(:server => server.downcase)
		call.getMatchHistoryById(summId)
		resp = call.response
		#Take most recent game
		match = resp['matches'].last
		#Get that games full details
		match_call = RiotApiCall.new(:server => server.downcase)
		match_call.getMatchByMatchId(match['matchId'].to_s)
		match_resp = match_call.response
		#CREATE GAME OBJECT : API CALLS COMPLETE 
		@game = Game.find_by(gameId: match_resp["matchId"], summoner_id: summId)
	
		
		if @game == nil
			@game = Game.new(:gameData => match_resp, :gameId => match_resp['matchId'], :summoner_id => summId)
			@game.save
			logger.info 'Game Updated'
			return @game.gameId
		else
			logger.info 'No New Game'
		end

		return 0
	end
end

