class Game < ActiveRecord::Base
	serialize :gameData
	belongs_to :summoner

	def self.update(params)
    	# Check if name is already connected to a number.
    	@summoner = params[:summoner]
    	server = params[:server]
		
		if (Time.now.to_i - @summoner.lastUpdated.to_i) > 900
			#If the summoner is due for a game update, update the games.
			request2 = "https://" + server.downcase + ".api.pvp.net/api/lol/" + server.downcase + "/" + ENV['MATCH_HISTORY_VERSION'].to_s + "/matchhistory/" + @summoner.summonerId.to_s + "?api_key=" + ENV['RIOT_API_KEY'].to_s
			call = RiotApiCall.new(:server => server.downcase, :api_call => request2)
			call.getMatchHistoryById
			resp = call.response
			logger.info "#{resp}"
			match = resp['matches'].last
			match_request = "https://" + server.downcase + ".api.pvp.net/api/lol/" + server.downcase + "/" + ENV['MATCH_VERSION'].to_s + "/match/" + match['matchId'].to_s + "?includeTimeline=true&api_key=" + ENV['RIOT_API_KEY'].to_s
			match_call = RiotApiCall.new(:server => server.downcase, :api_call => match_request)
			match_call.getMatchByMatchId
			match_resp = match_call.response
			@lame = Game.find_by(gameId: match_resp["matchId"], summoner_id: @summoner.id)
			
			
			if @lame == nil
				game = Game.new(:gameData => match_resp, :gameId => match_resp['matchId'], :summoner_id => @summoner.id)
				game.save
				logger.info 'Game Updated'
				@summoner.lastGameId = game.gameId
			else
				logger.info 'No New Game'
			end
	
			@summoner.lastUpdated = Time.now.to_i
			@summoner.save
			#logger.info "Game #{game.gameId} saved."
		end


		return @summoner
	end
end
